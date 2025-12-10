# WordPress Development Environment

This project provides a complete local development environment for WordPress using Docker. It includes custom-built containers for MariaDB, WordPress, and phpMyAdmin, all based on `alpine:3.23.0`.

## Features

- **Custom Docker Images**: Lightweight images based on Alpine Linux 3.23.0.
- **Persistent Storage**: 
  - WordPress files are mounted locally in `wordpress_data/` for easy theme/plugin development.
  - Database files are persisted in `mariadb_data/`.
- **Environment Configuration**: All sensitive configuration is managed via `.env` file.
- **Tools**: Includes phpMyAdmin for database management.

## Prerequisites

- Docker or Podman
- Docker Compose or Podman Compose

## Getting Started

1.  **Clone the repository** (if applicable).

2.  **Configure Environment Variables**:
    Copy the example environment file to create your local configuration:
    ```bash
    cp .env.example .env
    ```
    You can edit `.env` to change database credentials or other settings if needed.

3.  **Build and Start Containers**:
    Run the following command to build the images and start the services:
    ```bash
    docker-compose up -d --build
    ```
    *Or if using Podman:*
    ```bash
    podman-compose up -d --build
    ```
    - **MariaDB**: Port `3306`

## Podman Support

This project is fully compatible with **Podman**, including **Rootless Podman**.

- **Rootless Compatibility**: The configuration includes `:Z` volume flags for SELinux support and entrypoint scripts that handle permission management automatically.
- **Usage**: Simply use `podman-compose` instead of `docker-compose`.

## Directory Structurehttp://localhost:8080](http://localhost:8080)
    - **phpMyAdmin**: [http://localhost:8081](http://localhost:8081)
    - **MariaDB**: Port `3306`

## Directory Structure

- `mariadb/`: Dockerfile and entrypoint for the MariaDB service.
- `wordpress/`: Dockerfile and entrypoint for the WordPress service.
- `phpmyadmin/`: Dockerfile and entrypoint for the phpMyAdmin service.
- `mariadb_data/`: Local directory where database files are stored (ignored by git).
- `wordpress_data/`: Local directory where WordPress files are stored (ignored by git).
- `docker-compose.yml`: Defines the services and their relationships.

## Development

- **WordPress Files**: The `wordpress_data` directory is mapped to `/var/www/html` in the container. Any changes you make to files in this directory (e.g., creating a new theme or plugin) will be immediately reflected in the running WordPress instance.
- **Database**: The `mariadb_data` directory persists your database changes across container restarts and rebuilds.

## File Permissions

### WordPress Data
If you want to edit themes or plugins locally, you need ownership of the files in `wordpress_data`. However, the web server also needs write access for uploads and updates.

**Option 1: Allow everyone to write (Easiest for Development)**
```bash
sudo chmod -R 777 wordpress_data
```

**Option 2: Change ownership to your user**
This allows you to edit files, but might restrict the web server to read-only access (no uploads/updates) unless permissions are further adjusted.
```bash
sudo chown -R $USER:$USER wordpress_data
```

**Option 3: Add your user to the web server group (Secure & Recommended)**
This allows both you and the web server to write, without making files world-writable.

1.  Find the Group ID (GID) used by the container's web server. Run this in the project root after starting the containers:
    ```bash
    # Check the group ID of a file created by the container (e.g., index.php)
    ls -ln wordpress_data/index.php | awk '{print $4}'
    ```
    *Note: It will likely be a number like `100`, `101`, or `82`.*
    
    **Important:** If the output is `0`, the files are owned by `root`. **Do not** add your user to the `root` group. In this case, please use **Option 1** (`chmod 777`) instead.

2.  Add your user to that group.
    Replace `<GID>` with the number you found.
    ```bash
    # Create a group with that ID (if it doesn't exist). Ignore error if it exists.
    sudo groupadd -g <GID> docker-www || true
    
    # Add your user to the group (dynamically finds the group name for the GID)
    sudo usermod -aG $(getent group <GID> | cut -d: -f1) $USER
    ```
    *You may need to log out and back in for this to take effect.*

3.  Adjust file ownership and permissions:
    Replace `<GID>` with the number you found.
    ```bash
    # Ensure the web server group owns all files (fixes issues with root-owned files like wp-config.php)
    sudo chgrp -R <GID> wordpress_data
    
    # Set permissions to 775 (Owner/Group can write, Others can read)
    sudo chmod -R 775 wordpress_data
    ```

### Database Data
**Note:** Do not change permissions for `mariadb_data` manually. The database container manages its own permissions. Changing them may prevent the database from starting.

## Stopping the Environment

To stop the containers:
```bash
docker-compose down
```

To stop the containers and remove volumes (WARNING: this will delete your database and wordpress files if you haven't backed them up, although the bind mounts usually persist on the host):
```bash
docker-compose down -v
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

