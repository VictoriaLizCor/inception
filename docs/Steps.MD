# Incenption (deployment in Debian enviroment)

## Debian or alpine instalation in VirtualMachine 

###  Set up Debian Bullseye distribution enviroment

1. **Download and install distribution**
	https://saimei.ftp.acc.umu.se/mirror/cdimage/archive/latest-oldstable/amd64/iso-cd/debian-11.11.0-amd64-netinst.iso

2. **Add user to sudo list**

	To add a user to the sudo group on a Debian system, follow these steps:

	a. *Switch to the root user:*

		```sh
		su -
		```

	b. *Add the user to the sudo group:*

		Replace `your_username` with the actual username you want to add to the sudo group.

		```sh
		usermod -aG sudo your_username
		```

	c. *Verify the user is added to the sudo group:*

		```sh
		groups your_username
		```

You should see `sudo` listed among the groups for the user.

4. **Log out and log back in**

5. **Install and configure SSH server inside the VM:**
   sudo apt-get install -y openssh-server
   sudo systemctl enable ssh
   sudo systemctl start ssh
   sudo systemctl status ssh
   ```
6. **Check the IP address of the VM:**
   ```sh
   ip addr show
   ```

7. **Check if the SSH port (22) is open:**
   ```sh
   sudo netstat -tuln | grep :22
   ```
8. **Create $HOME/.ssh/config file**
	```sh
	Host VMName
    HostName localhost
    Port 4242
    User VMHostName
    IdentityFile ~/.ssh/id_rsa
	```
with this it is possible to open files in VSCode

9. **Connection to VM using VSCODE**

	To verify if you are connected to a remote machine via SSH in Visual Studio Code, you can look for the following indicators:

	a. **Remote Indicator in the Status Bar:**
	- When you are connected to a remote machine, you will see a green remote indicator in the lower-left corner of the Visual Studio Code window. It will display the name of the SSH host you are connected to.
	- For example, it might show something like `SSH: username@hostname`.

	b. **Remote Explorer:**
	- Open the Remote Explorer view by clicking on the Remote Explorer icon in the Activity Bar on the side of the window.
	- In the Remote Explorer, you should see the list of remote connections, and the one you are currently connected to will be highlighted.

	c. **Command Palette:**
	- Open the Command Palette by pressing `F1` or `Ctrl+Shift+P`.
	- Type `Remote-SSH: Show Log` and select it. The log will show the connection details and confirm if you are connected to the remote machine.

	d. **File Explorer:**
	- In the File Explorer view, you should see the file system of the remote machine. The root directory will reflect the remote machine's file system, not your local machine's.

These indicators will help you confirm that you are connected to a remote machine via SSH in Visual Studio Code.


#### Confugure VirtualBox Guest additions

 * Configure to be able to run from guest enviroment
The error message indicates that the guest execution service is not ready. This typically means that the VirtualBox Guest Additions are not fully initialized or not running correctly.


Here are some steps to troubleshoot and resolve this issue:

1. **Ensure Guest Additions are installed:**
   Make sure that the VirtualBox Guest Additions are installed in the VM. You can check this by running the following command inside the VM:
	```sh
	lsmod | grep vboxguest
	```
   If the module is not listed, you need to install the Guest Additions.

2. **Install Guest Additions:**
   If Guest Additions are not installed, follow these steps to install them:

	a. Start the VM with a GUI:
		```sh
		VBoxManage startvm "Debian" --type headless
		```

	b. Mount the Guest Additions ISO:
		```sh
		VBoxManage storageattach "Debian" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium additions
		```

	c. Inside the VM, mount the ISO and run the installer. For example, on a Debian-based system:
		```sh
		sudo mount /dev/cdrom /mnt
		sudo /mnt/VBoxLinuxAdditions.run
		```

	d. Reboot the VM:
		```sh
		sudo reboot
		```

3. **Verify Guest Additions are running:**
   After rebooting, check if the Guest Additions are running by executing inside VM:
	```sh
	lsmod | grep vboxguest
	```

4. **Run the guestcontrol command again:**
   Once the Guest Additions are confirmed to be running, try running the `guestcontrol` command again:
   ```sh
   VBoxManage guestcontrol "Debian" run --username lilizarr --password lilizarr --exe "/bin/ls" -- /bin/ls /home
   ```

If you still encounter issues, ensure that the VM is fully booted and that the Guest Additions services are running. You can also check the VM's logs for any errors related to Guest Additions.

 * Start machine
	```sh
	VBoxManage startvm "Debian"
	```

	```sh
	VBoxManage storageattach "Debian" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium additions
	```
	```sh
	VBoxManage guestcontrol "Debian" run --username lilizarr --password lilizarr --exe "/bin/ls" -- /bin/ls /home
	```

	```sh
	VBoxManage storageattach "Debian" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium additions
	```

#### Enable SSH connection

To SSH into your VM from the host machine, you need to set up port forwarding in VirtualBox, as the NAT mode does not allow direct access to the VM's IP address from the host.

Here are the steps to set up port forwarding:

1. **Open VirtualBox:**
   Open the VirtualBox application on your host machine.

2. **Select your VM:**
   Select your Debian VM and click on "Settings".

3. **Go to Network settings:**
   In the settings window, go to the "Network" section.

4. **Open Advanced settings:**
   Click on the "Advanced" dropdown to reveal additional settings.

5. **Open Port Forwarding:**
   Click on the "Port Forwarding" button.

6. **Add a new rule:**
   Add a new port forwarding rule with the following details:
   - **Name:** SSH
   - **Protocol:** TCP
   - **Host IP:** (leave empty)
   - **Host Port:** 4242 (or any other available port on your host)
   - **Guest IP:** (leave empty)
   - **Guest Port:** 22

7. **Save the settings:**
   Click "OK" to save the port forwarding rule and close the settings window.

Now you can SSH into your VM using the forwarded port. On your host machine, use the following command:

```sh
ssh -p 4242 lilizarr@localhost
```

### useful commands

1. `Start`
	```sh
	VBoxManage startvm "Debian" --type headless
	```
2. `Shutdown` forced
	```sh
	VBoxManage controlvm "Debian" poweroff
	```
3. `Shutdown` recommended
	```sh
	VBoxManage controlvm "Debian" acpipowerbutton
	```
4. Check VM `status`
	```sh
	VBoxManage showvminfo "Debian"
	```
5. Check if `VM Guest Additions` are installed 
	```sh
	VBoxManage guestproperty enumerate "Debian"
	```
6. Check the `status of Guest Additions`:
	```sh
	VBoxManage guestproperty get "Debian" "/VirtualBox/GuestAdd/Version"
	```
7. List running VMs:
	```sh
	VBoxManage list runningvms
	```
9. Send files thorough ssh
` scp -r /path/to/local/directory Debian:/path/to/remote/directory`



# Packages Installation 

## ping
```bash
sudo apt update
sudo apt install iputils-ping
```

## Docker Instalation

After stablishing connection throught ssh. 

If your user is not in the sudoers file, you need to switch to the root user to perform administrative tasks. Here are the steps:

1. **Switch to the root user:**

```sh
su -
```

2. **Install Docker:**

```sh
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/gpg | \
gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
# apt-get install docker.io docker-compose -y
```

## Docker commands

### List all Docker containers (running and stopped)
`docker ps -a`

### List only running Docker containers
`docker ps`

### Start a Docker container
`docker start <container_id>`

### Stop a Docker container
`docker stop <container_id>`

### Remove a Docker container
`docker rm <container_id>`

### Remove all stopped containers
`docker container prune`

### List all Docker images
`docker images`

### Remove a Docker image
`docker rmi <image_id>`

### Build a Docker image from a Dockerfile
`docker build -t <image_name> .`

### Run a Docker container from an image
`docker run -d -p <host_port>:<container_port> <image_name>`

### Run a Docker container with an interactive terminal
`docker run -it <image_name> /bin/bash`

### Show logs from a Docker container
`docker logs <container_id>`

### Follow logs from a Docker container
`docker logs -f <container_id>`

### Execute a command in a running Docker container
`docker exec -it <container_id> <command>`

### Show Docker system information
`docker info`

### Show Docker version
`docker version`

### Remove all unused data (containers, images, networks, volumes)
`docker system prune -a`

## Use of docker TSL certificates

To achieve this, you need to set up Docker secrets to store confidential information, configure NGINX as the only entry point using port 443 with TLSv1.2 or TLSv1.3, and use Docker Compose to manage the services. Here are the steps:

1. **Create Docker Secrets:**

First, create the secrets you need. For example, let's create a secret for the TLS certificate and key.

```sh
echo "your_tls_certificate_content" | docker secret create tls_cert -
echo "your_tls_key_content" | docker secret create tls_key -
```

2. **Create `docker-compose.yml` File:**

Create a `docker-compose.yml` file to define your services and networks.

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    ports:
      - "443:443"
    secrets:
      - tls_cert
      - tls_key
    volumes:
      - /etc/nginx/conf.d
    networks:
      - mynetwork
    deploy:
      placement:
        constraints: [node.role == manager]
    configs:
      - source: nginx_conf
        target: /etc/nginx/nginx.conf

networks:
  mynetwork:
    driver: bridge

secrets:
  tls_cert:
    external: true
  tls_key:
    external: true

configs:
  nginx_conf:
    file: ./nginx.conf
```

3. **Create NGINX Configuration File:**

Create an `nginx.conf` file to configure NGINX to use TLSv1.2 or TLSv1.3.

```nginx
events {}

http {
    server {
        listen 443 ssl;
        ssl_certificate /run/secrets/tls_cert;
        ssl_certificate_key /run/secrets/tls_key;
        ssl_protocols TLSv1.2 TLSv1.3;

        location / {
            proxy_pass http://your_backend_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

4. **Deploy the Stack:**

Deploy the stack using Docker Compose.

```sh
docker-compose up -d
```

This setup ensures that:

- Docker secrets are used to store the TLS certificate and key.
- NGINX is configured as the only entry point on port 443.
- TLSv1.2 or TLSv1.3 is used for secure communication.
- The NGINX configuration is stored in a Docker config and mounted into the container.

Make sure to replace `"your_tls_certificate_content"` and `"your_tls_key_content"` with your actual TLS certificate and key content, and `http://your_backend_service` with the actual backend service URL.

## Creating directories

```bash
# Create the main directories
mkdir -p .secrets srcs/requirements/{mariadb,nginx,wordpress}/conf
mkdir -p .secrets srcs/requirements/{mariadb,nginx,wordpress}/tools
# Create the files in the secrets directory
touch .secrets/{credentials.txt,db_password.txt,db_root_password.txt}

# Create the files in the srcs directory
touch srcs/{docker-compose.yml,.env}

# Create the files in the mariadb, nginx, and wordpress directories
touch srcs/requirements/{mariadb,nginx,wordpress}/config/config.cnf
touch srcs/requirements/{mariadb,nginx,wordpress}/{Dockerfile,.dockerignore}
```

If you are working over an SSH connection to a local virtual machine and encountering issues related to the locale and GUI applications, you can address these issues by configuring the locale settings and ensuring that you are not attempting to run GUI applications that require a display server.

### 1. Configure Locale Settings

Ensure that the locale settings are correctly configured on your virtual machine. You can do this by updating your locale settings in the virtual machine.

#### Update Locale Settings

1. **Edit the locale configuration file**:
   - Open the 

locale

 file in a text editor.

   ```sh
   sudo nano /etc/default/locale
   ```

2. **Set the locale to `en_US.UTF-8`**:
   - Add or update the following lines in the file:

   ```plaintext
   LANG=en_US.UTF-8
   LANGUAGE=en_US:en
   LC_ALL=en_US.UTF-8
   ```

3. **Generate the locale**:
   - Run the following commands to generate the locale:

   ```sh
   	export LANG=en_US.UTF-8
	export LANGUAGE=en_US:en
	export LC_ALL=en_US.UTF-8
   ```

4. **Reboot the virtual machine**:
   - Reboot the virtual machine to apply the changes.

   ```sh
   sudo reboot
   ```

### forwarding GUI application 
To connect to a remote machine via SSH and use Firefox to open graphical applications, you need to set up X11 forwarding. Here are the steps to achieve this:

1. **Ensure X11 Forwarding is Enabled on the SSH Server**:
   On the remote machine, make sure that X11 forwarding is enabled in the SSH server configuration file (

sshd_config

):

   ```sh
   sudo nano /etc/ssh/sshd_config
   ```

   Ensure the following lines are present and uncommented:

   ```sh
   X11Forwarding yes
   X11DisplayOffset 10
   X11UseLocalhost yes
   ```

   Restart the SSH service to apply the changes:

   ```sh
   sudo systemctl restart ssh
   ```

2. **Install an X Server on Your Local Machine**:
   On your local machine, you need an X server to display the graphical applications. If you are using Linux, you likely already have one installed. If you are using Windows, you can install an X server like Xming or VcXsrv. On macOS, you can use XQuartz.

3. **Connect to the Remote Machine with X11 Forwarding**:
   Use the `-X` or `-Y` option with the `ssh` command to enable X11 forwarding. The `-Y` option is more permissive and may be necessary for some applications.

   ```sh
   ssh -Y username@remote_host
   ```

4. **Run Firefox on the Remote Machine**:
   Once connected to the remote machine via SSH with X11 forwarding enabled, you can start Firefox:

   ```sh
   firefox &
   ```

   This command will open Firefox on the remote machine, but the display will be forwarded to your local machine.

### Example

1. **Enable X11 Forwarding on the SSH Server**:
   ```sh
   sudo nano /etc/ssh/sshd_config
   ```

   Ensure the following lines are present and uncommented:

   ```sh
   X11Forwarding yes
   X11DisplayOffset 10
   X11UseLocalhost yes
   ```

   Restart the SSH service:

   ```sh
   sudo systemctl restart ssh
   ```

2. **Install an X Server on Your Local Machine**:
   - **Linux**: Typically already installed.
   - **Windows**: Install Xming or VcXsrv.
   - **macOS**: Install XQuartz.

3. **Connect with X11 Forwarding**:
   ```sh
   ssh -Y username@remote_host
   ```

4. **Run Firefox**:
   ```sh
   firefox &
   ```

This setup will allow you to run Firefox on the remote machine and display it on your local machine via SSH with X11 forwarding.