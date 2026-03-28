# Inception Project

## Setup
To set up the Inception project, ensure you have Docker and Docker Compose installed on your machine. Follow these steps to get started:

1. Clone the repository:
   ```bash
   git clone https://github.com/VictoriaLizCor/inception.git
   cd inception
   ```
2. Build the Docker images:
   ```bash
   docker-compose build
   ```
3. Run the services:
   ```bash
   docker-compose up -d
   ```

## Usage
Once the services are up and running, you can access them as follows:
- Web application: [http://localhost:8080](http://localhost:8080)
- Database: Access via the service defined in docker-compose.yml.

Use the Docker commands to manage the containers:
- Stop services:
   ```bash
   docker-compose down
   ```

## Services Overview
The Inception project consists of the following services:
- **Web App**: The main application running on **port 8080**.
- **Database**: A persistent database to store user data. Interaction should be handled through the web app.

## Troubleshooting
If you encounter issues, consider the following steps:
1. Check if Docker is running: `docker info`
2. View logs of a specific service:
   ```bash
   docker-compose logs <service_name>
   ```
3. Ensure ports are not conflicting with other applications.

## Make Targets
The project uses a Makefile to streamline operations. Here are some of the available make targets:
- `make build`: Build the Docker images.
- `make up`: Start the services using Docker Compose.
- `make down`: Stop the services that were started.

For additional targets, review the Makefile directly.
