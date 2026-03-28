# Inception (Docker) — Nginx + WordPress + MariaDB

This project provisions a small **Docker Compose** web stack with:

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
- `srcs/docker-compose.yml` — Compose definition (`nginx` / `wordpress` / `mariadb`)
- `srcs/requirements/` — Dockerfiles and configs:
  - `nginx/`
  - `wordpress/`
  - `mariadb/`
- `generateSecrets.sh` — generates `srcs/.env` + `secrets/*` by decrypting `.tmp.enc`
- `docs/` — extra notes (Docker steps, secrets, etc.)

---

## Prerequisites

- Linux environment (some make targets check for **Debian 11 (bullseye)**)
- `docker` and `docker compose`
- `gpg` (used by `generateSecrets.sh` to decrypt `.tmp.enc`)
- `make`

> Some Make targets modify `/etc/hosts` (via sudo) to map `127.0.0.1 ${USER}.42.fr`.

---

## Quick start

From the repository root:

```bash
make
```

`make` runs the default target which:

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
- Healthcheck: `https://${DOMAIN_NAME}/site-health.php`

### WordPress

- Runs PHP-FPM 7.4
- Uses WP-CLI (via `wp_install.sh`) to:
  - download/configure WordPress
  - install core
  - create an extra user
  - set permalinks + basic options
  - install a theme/plugins (as scripted)
- Exposes port **9000** (internal)

### MariaDB

- MariaDB server **10.5**
- Uses Docker secrets for root/user passwords
- Initializes the database via `init_mariadb.sh` and `init.sql`
- Exposes port **${DB_PORT}** (from `.env`)

---

## Useful make targets

- `make` / `make all` — build + up + show
- `make run` — start services sequentially (mariadb → wordpress → nginx)
- `make up` / `make down` — compose up/down
- `make clean` / `make fclean` — cleanup (⚠️ `fclean` removes volumes + secrets)
- `make nglog` / `make wplog` / `make logm` — logs
- `make ngbash` / `make twp` / `make mdb` — shell into containers

---

## Troubleshooting

- **Secrets/.env not created:** run `make secrets` and ensure you have the correct GPG key for `.tmp.enc`.
- **Hostname not resolving:** ensure `/etc/hosts` contains `127.0.0.1 ${USER}.42.fr` (or run the make target that adds it).
- **Unhealthy containers:** check logs (`make nglog`, `make wplog`, `make logm`) and healthchecks.

---

## Security note

This repo generates and uses secrets locally. Do **not** commit real secrets. Treat `secrets/` and `srcs/.env` as sensitive.
