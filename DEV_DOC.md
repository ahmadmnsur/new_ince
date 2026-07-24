# DEV_DOC — Inception (Developer)

## 1) Set up the environment from scratch

### Prerequisites
- Linux
- Docker Engine
- Docker Compose (plugin: `docker compose`)
- GNU Make

### Repository layout
- `srcs/docker-compose.yml`: service definitions
- `srcs/requirements/*`: Docker build contexts (Dockerfiles + configs + tools)
- `secrets/`: password files mounted into containers
- `Makefile`: developer targets

### Configuration files
#### `.env`
Create `srcs/.env` (not committed) to define non-secret configuration.
The Compose file references `env_file: .env` for MariaDB and WordPress.

Minimum expected variables (based on entrypoints/compose):
- `VOLUMES_PATH` (host path used by volume bind backing)
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_ROOT_PASSWORD_FILE` (e.g., `/run/secrets/db_root_password.txt`)
- `MYSQL_PASSWORD_FILE` (e.g., `/run/secrets/db_password.txt`)
- `WP_URL`, `WP_TITLE`
- `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`, `WP_ADMIN_PASSWORD_FILE`
- `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASSWORD_FILE`

Keep secrets out of `.env` by using `*_FILE` variables pointing to `/run/secrets/...`.

#### Secrets
Populate the files in `secrets/`:
- `db_root_password.txt`
- `db_password.txt`
- `wp_admin_password.txt`
- `wp_user_password.txt`

They are mounted into containers by Compose:
- `../secrets:/run/secrets:ro`

## 2) Build and launch (Makefile + Docker Compose)

### Makefile targets
- `make up`: creates host data dirs and runs `docker compose up -d --build`
- `make down`: `docker compose down`
- `make start` / `make stop`
- `make logs`: follow logs
- `make clean`: prune docker resources
- `make fclean`: removes `/home/ahmmanso/data` (as configured in `Makefile`)

### Compose entrypoint
The Compose file is `srcs/docker-compose.yml`.

Services:
- `mariadb`: builds `srcs/requirements/mariadb`
- `wordpress`: builds `srcs/requirements/wordpress` (depends on healthy mariadb)
- `nginx`: builds `srcs/requirements/nginx` and publishes `443:443`

## 3) Commands to manage containers, networks, and volumes

### Inspect running services
- `docker compose -f srcs/docker-compose.yml ps`
- `docker compose -f srcs/docker-compose.yml logs -f`

### Rebuild a single service
- `docker compose -f srcs/docker-compose.yml build wordpress`
- `docker compose -f srcs/docker-compose.yml up -d wordpress`

### Execute a shell inside a container
- `docker exec -it nginx bash`
- `docker exec -it wordpress bash`
- `docker exec -it mariadb bash`

### Volumes
List volumes:
- `docker volume ls`
Inspect volume:
- `docker volume inspect <volume_name>`

Remove volumes (data loss):
- `docker compose -f srcs/docker-compose.yml down -v`

### Networks
- `docker network ls`
- `docker network inspect inception_network`

## 4) Where data is stored and how it persists

### Docker Compose volumes
`srcs/docker-compose.yml` defines two volumes:
- `mariadb_data` mounted at `/var/lib/mysql`
- `wordpress_data` mounted at `/var/www/html`

They are configured with `driver_opts`:
- `type: none`
- `o: bind`
- `device: ${VOLUMES_PATH}/...`

So persistence is achieved by storing data on the host filesystem under the directory specified by `VOLUMES_PATH`.

### Default host data path used by the Makefile
The Makefile also creates:
- `/home/ahmmanso/data/wordpress`
- `/home/ahmmanso/data/mariadb`

Ensure `VOLUMES_PATH` is consistent with your expected storage location.
If you want the Makefile and Compose to point to the same place, set `VOLUMES_PATH=/home/ahmmanso/data` in `srcs/.env`.
