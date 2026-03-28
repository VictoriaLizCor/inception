# Inception (Docker) — Nginx + WordPress + MariaDB

This project is a classic **Docker-based system administration** exercise: it provisions a small web stack using **Docker Compose** with:

- **Nginx** (TLS/HTTPS reverse proxy)
- **WordPress** (PHP-FPM + WP-CLI auto-install)
- **MariaDB** (database, initialized with an SQL template)

The repository includes a `Makefile` that automates volume creation, secrets generation, image builds, and container lifecycle commands.

---

## Stack

- Docker / Docker Compose
- Nginx (HTTPS on port defined in `.env`)
- WordPress + PHP-FPM 7.4 + WP-CLI
- MariaDB 10.5
- Docker **secrets** for DB passwords + TLS key/cert + WordPress credentials

---

## Repository structure

- `Makefile` — main entrypoint for building/running
- `srcs/docker-compose.yml` — Compose definition (nginx / wordpress / mariadb)
- `srcs/requirements/` — Dockerfiles and configs:
  - `nginx/`
  - `wordpress/`
  - `mariadb/`
- `generateSecrets.sh` — generates `srcs/.env` + `secrets/*` by decrypting `.tmp.enc`
- `docs/` — extra notes (Docker steps, secrets, etc.)

---

## Prerequisites

- Linux environment (the make targets include checks for **Debian 11 bullseye** in some flows)
- `docker` and `docker compose`
- `gpg` (used by `generateSecrets.sh` to decrypt `.tmp.enc`)
- `make`

> Note: some Make targets modify `/etc/hosts` (via sudo) to map `127.0.0.1 ${USER}.42.fr`.

---

## Quick start

From the repository root:

```bash
make
```

`make` runs the default target:

- creates bind-mount volume directories under `~/data`
- generates secrets + `.env` (prompts for a GPG decryption key)
- builds images
- starts containers
- shows container/image/volume/network status

---

## How secrets and env work

### What gets created
Running `make secrets` (or `make`, which depends on it) will:

- create a `secrets/` directory
- decrypt `.tmp.enc` into:
  - `srcs/.env` (runtime configuration)
  - `secrets/ssl/privkey.key` and `secrets/ssl/fullchain.crt` (TLS for nginx)
- generate Docker secret files:
  - `secrets/db_root_password.txt`
  - `secrets/db_password.txt`
  - `secrets/credentials.txt` (WordPress & DB configuration)

### Why you are prompted for a key
`generateSecrets.sh` decrypts `.tmp.enc` using `gpg` and asks:

```
Enter decryption key:
```

If decryption fails, it exits with an error.

---

## Services overview (docker-compose)

### Volumes (bind mounts)
Compose defines two bind-mounted volumes (paths come from `.env`):

- `db-vol` → `${MARIADB_VOLUME}` mounted at `/var/lib/mysql`
- `wp-vol` → `${WORDPRESS_VOLUME}` mounted at `/var/www/html`

The `Makefile` prepares defaults under:

- `~/data/mariadb`
- `~/data/wordpress`

### Network
Custom bridge network name is taken from `${NETWORK_NAME}`.

### Nginx
- Listens on **443** with TLS
- Uses Docker secrets for:
  - `ssl_key` → `/run/secrets/ssl_key`
  - `ssl_cert` → `/run/secrets/ssl_cert`
- Proxies PHP requests to `wordpress:9000`
- Has a healthcheck hitting: `https://${DOMAIN_NAME}/site-health.php`

### WordPress
- Runs PHP-FPM 7.4
- Uses WP-CLI to:
  - download/configure WordPress
  - install core
  - create an extra user
  - update rewrite rules / options
  - install theme/plugins (as scripted)
- Uses `credentials` secret at `/run/secrets/credentials`

### MariaDB
- Uses secrets:
  - root password
  - user password
- Initializes DB using an SQL template and startup script in the image build stage.

---

## Common Make targets

### Main lifecycle
- `make` / `make all` — build + up + show
- `make run` — build/start in sequence (mariadb → wordpress → nginx)
- `make up` — `docker compose up -d`
- `make down` — `docker compose down -v --rmi local`
- `make stop` — stop containers

### Cleaning
- `make clean` — stop/down and remove logs
- `make fclean` — aggressive cleanup (containers/images/volumes/networks + remove secrets)

### Individual services
- `make build-nginx` / `make up-nginx` / `make run-nginx`
- `make build-wordpress` / `make up-wordpress` / `make run-wordpress`
- `make build-mariadb` / `make up-mariadb` / `make run-mariadb`

### Diagnostics helpers
- `make show` / `make showAll` — list containers/images/volumes/networks
- `make wplog` / `make nglog` / `make logm` — logs
- `make ngbash` / `make twp` / `make mdb` / `make rmdb` — shell into containers

---

## Accessing the site

This project typically maps a host like:

- `${USER}.42.fr`

The Makefile includes a helper that adds to `/etc/hosts`:

```
127.0.0.1 ${USER}.42.fr
```

Once containers are healthy, open:

- `https://<DOMAIN_NAME>/`

(Your `DOMAIN_NAME` is provided by the decrypted `.env` / generated `credentials.txt`.)

---

## Troubleshooting

### 1) Secrets / .env not created
- Run: `make secrets`
- Ensure `gpg` is installed
- Use the correct decryption key for `.tmp.enc`

### 2) Containers stuck unhealthy
Check health and logs:

```bash
make showAll
make nglog
make wplog
make logm
```

### 3) Volume permission issues
This setup uses bind mounts under `~/data`. If ownership/permissions get messy:

```bash
make fclean
make
```

(Warning: `fclean` removes volumes and secrets.)

### 4) Hostname not resolving
If `https://<DOMAIN_NAME>` doesn’t resolve, ensure `/etc/hosts` contains the mapping to `127.0.0.1`.

---

## Documentation

See `docs/`:
- `docs/Docker.MD`
- `docs/Steps.MD`
- `docs/secrets.MD`
- `docs/mariadb.MD`
- `docs/en.subject.pdf`

---

## Disclaimer

This repository generates and uses secrets locally. Do **not** commit real secrets. Treat `secrets/` and `srcs/.env` as sensitive.
