# Docker WordPress with Nginx and Certbot

This project sets up a WordPress environment with Nginx and automatic SSL certificate management via Certbot using Docker. It is designed to make it easy to deploy a secure, production-ready WordPress site with SSL encryption.

## Features

- **WordPress**: The latest stable version of WordPress.
- **Nginx**: Acts as a reverse proxy with SSL support.
- **Certbot**: Automatically generates and renews SSL certificates.
- **MySQL**: Used as the database for WordPress.
- **One-click deployment**: A script to simplify setup and configuration.

## Prerequisites

- **Docker** and **Docker Compose** installed on your machine.
  - To install Docker, follow the official [Docker installation guide](https://docs.docker.com/get-docker/).
  - To install Docker Compose, follow the official [Docker Compose installation guide](https://docs.docker.com/compose/install/).

## Getting Started

### 1. Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/yourusername/docker-wordpress-nginx-certbot.git
cd docker-wordpress-nginx-certbot
```

### 2. Configure the Environment

To configure the necessary environment variables (such as database credentials, domain name, and SSL email), you can use the `.env` file.

#### Manually Edit the `.env` File

Create or modify the `.env` file in the project root directory:

```bash
# .env example

# WordPress Database Configuration
TAGWORD_DB_NAME=wordpress_tagword
TAGWORD_DB_USER=wordpress_user
TAGWORD_DB_PASSWORD=yourpassword
TAGWORD_DB_ROOT_PASSWORD=rootpassword

# Domain and SSL Configuration
DOMAIN_NAME=tagword.tech
SSL_EMAIL=your-email@example.com
```

- **TAGWORD_DB_NAME**: Name of the WordPress database.
- **TAGWORD_DB_USER**: Username for accessing the database.
- **TAGWORD_DB_PASSWORD**: Password for the WordPress database.
- **TAGWORD_DB_ROOT_PASSWORD**: Root password for the MySQL database.
- **DOMAIN_NAME**: Your website's domain name (e.g., `tagword.tech`).
- **SSL_EMAIL**: Your email address for SSL certificate registration.

#### One-click Deployment (Optional)

Alternatively, you can use the provided `deploy.sh` script to automatically configure the `.env` file, start the containers, and generate SSL certificates.

### 3. Run the Deployment Script

If you prefer an automated setup, simply run the one-click deployment script:

```bash
chmod +x deploy.sh
./deploy.sh
```

This script will:
- Prompt you for the database and SSL details (if not already configured in `.env`).
- Automatically create the `.env` file.
- Start the necessary Docker containers.
- Generate SSL certificates via Certbot for your specified domain.

### 4. Start the Services

Once the `.env` file is configured (or the script has created it for you), you can start the Docker containers using:

```bash
docker-compose up -d
```

This will start the following services:
- **Nginx**: A reverse proxy to forward requests to WordPress.
- **WordPress**: The WordPress application.
- **MySQL**: The MySQL database for WordPress.
- **Certbot**: To manage SSL certificates for secure HTTPS connections.

### 5. Generate SSL Certificates

If you did not use the `deploy.sh` script, you can manually run Certbot to generate SSL certificates:

```bash
docker exec -it certbot certbot certonly --webroot --webroot-path=/var/www/certbot --email your-email@example.com --agree-tos --no-eff-email -d tagword.tech -d www.tagword.tech
```

### 6. Access Your WordPress Site

Once the containers are up and running, you can access your WordPress site via `https://tagword.tech` (or your configured domain name).

## Project Structure

```
docker-wordpress-nginx-certbot/
│
├── docker-compose.yaml         # Docker Compose configuration to define services
├── nginx.conf                  # Nginx configuration for reverse proxy and SSL
├── .env                        # Environment variables for sensitive configurations
├── deploy.sh                   # One-click deployment script
├── README.md                   # Project documentation
└── data/                        # Persistent data for certificates, WordPress, and MySQL
    ├── certbot/
    ├── wordpress/
    └── mysql/
```

## Notes

- **SSL Certificates**: Certbot will automatically generate SSL certificates for your specified domain (via the `certbot` service). These certificates will be stored in `data/certbot/`.
- **Data Persistence**: The WordPress and MySQL containers use Docker volumes to persist data across container restarts. Volumes are defined in the `docker-compose.yaml` file under `wordpress_tagword_data` and `db_tagword_data`.

## Troubleshooting

- **Missing Docker Compose**: Ensure that Docker Compose is installed on your machine. You can verify by running `docker-compose --version`.
- **Permissions**: If you encounter permission errors with Docker, ensure your user is added to the `docker` group. You can refer to the [official Docker documentation](https://docs.docker.com/engine/install/linux-postinstall/) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

