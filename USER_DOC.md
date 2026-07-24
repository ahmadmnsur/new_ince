# USER_DOC — Inception (User / Admin)

## Overview: what services are provided
This stack provides a standard WordPress deployment with HTTPS:

- **Nginx** (container: `nginx`)
  - Exposes **HTTPS on port 443** to the host.
  - Serves static files and forwards PHP requests to WordPress (PHP-FPM).

- **WordPress (PHP-FPM)** (container: `wordpress`)
  - Runs the WordPress application.
  - Uses WP-CLI during first start to download/configure/install WordPress.

- **MariaDB** (container: `mariadb`)
  - Stores WordPress data.
  - Initializes database + user on first start.

All services communicate on an internal **Docker bridge network** named `inception_network`.

## Start / stop the project
From the repository root:

- Start (build if needed): `make up`
- Stop (keeps volumes/data): `make down`
- Stop without removing containers: `make stop`
- Start existing containers: `make start`
- Restart: `make restart`

Logs:
- Follow logs: `make logs`

Cleanup:
- Remove unused Docker resources: `make clean`
- Also remove persisted data directory (`/home/ahmmanso/data`): `make fclean`

## Access the website and the admin panel
- Website: `https://<host-or-domain>/`
- Admin panel: `https://<host-or-domain>/wp-admin`

Notes:
- Nginx uses a **self-signed certificate** by default, so the browser may warn you.
- Only port **443** is published to the host.

## Locate and manage credentials
### Where credentials are stored
This project stores passwords in files under `secrets/` (repository root), mounted read-only into containers at `/run/secrets`.

Expected files:
- `secrets/db_root_password.txt`
- `secrets/db_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`
- `secrets/credentials.txt` (optional / informational)

### How they are used
At runtime, entrypoint scripts read these files (paths are provided via environment variables in `srcs/.env`) and use them to:
- set the MariaDB root password
- create the WordPress database user/password
- set the WordPress admin and additional user password

### Rotation
To rotate a password:
1. Update the corresponding file in `secrets/`.
2. Restart the related service(s).

Important: if you already initialized the database and want passwords/users to be re-provisioned, you may need to remove the database volume/data (this will delete WordPress content).

## Check that services are running correctly
### Containers status
Use Docker Compose to check container state:
- `docker compose -f srcs/docker-compose.yml ps`

### Health
The MariaDB service has a healthcheck. You can inspect it with:
- `docker inspect mariadb --format '{{json .State.Health}}' | jq .`

### Basic functional checks
- HTTPS endpoint:
  - Open `https://<host-or-domain>/` in a browser.
- Verify Nginx is up:
  - `docker logs nginx`
- Verify WordPress (PHP-FPM) is up:
  - `docker logs wordpress`
- Verify MariaDB is up:
  - `docker logs mariadb`

### Data persistence
WordPress files and the database are persisted via volumes mapped to a host directory (configured by `VOLUMES_PATH`).
If you stop/start containers, data should remain.
