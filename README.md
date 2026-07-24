*This project has been created as part of the 42 curriculum by ahmmanso.*

# Inception

## Description
**Inception** is a system-administration project where the goal is to build a small, production-like web stack using **Docker** and **Docker Compose**.

This repository deploys a WordPress website served over **HTTPS** with:
- **Nginx** as the TLS reverse proxy / web server
- **WordPress (PHP-FPM)** as the application
- **MariaDB** as the database

The stack is built from custom images (no pre-built WordPress/MariaDB images) and is wired together through an isolated Docker network and persistent storage.

### What is included (sources)
- `srcs/docker-compose.yml`: defines the 3 services, network, and volumes
- `srcs/requirements/nginx/`: Nginx image + TLS certificate generation
- `srcs/requirements/wordpress/`: PHP-FPM + WP-CLI based setup
- `srcs/requirements/mariadb/`: MariaDB initialization and user/database provisioning
- `secrets/`: credentials/password files mounted read-only into containers
- `Makefile`: convenience targets to build, start, stop, and clean the stack

### Main design choices
- **One service per container** (Nginx, WordPress, MariaDB) to keep responsibilities separated.
- **Bridge network** (`inception_network`) so containers communicate by service name (e.g., `mariadb`, `wordpress`) without exposing internal ports to the host.
- **TLS termination in Nginx** on port `443` using a self-signed certificate generated at build time.
- **Persistent data** using Docker volumes backed by **bind-mount** directories (configured via `VOLUMES_PATH`).
- **Secrets as files** mounted into `/run/secrets` and read by entrypoints.

### Comparisons (required)
#### Virtual Machines vs Docker
- **Virtual Machines (VMs)** virtualize hardware and run a full guest OS per VM. They provide strong isolation but are heavier (more CPU/RAM/disk), slower to boot, and harder to replicate quickly.
- **Docker containers** virtualize at the OS level (namespaces/cgroups) and share the host kernel. They are lightweight, start fast, and are ideal for reproducible deployments.

#### Secrets vs Environment Variables
- **Environment variables** are convenient, but can leak through process listings, logs, shell history, or misconfigured debugging output.
- **Secrets (files)** keep sensitive values out of image layers and Compose files, can be mounted read-only, and are easier to rotate by replacing files without rebuilding images. In this project, password files are mounted to `/run/secrets`.

#### Docker Network vs Host Network
- **Docker bridge networks** isolate container traffic, offer automatic DNS by service name, and let you expose only the ports you want (here only `443`).
- **Host networking** removes that isolation and binds container ports directly to the host network stack, increasing the risk of port conflicts and reducing separation between services.

#### Docker Volumes vs Bind Mounts
- **Docker named volumes** are managed by Docker and are portable across hosts but opaque to browse without Docker tooling.
- **Bind mounts** map a specific host directory into a container. They are easy to inspect/backup with normal tools but are host-path dependent.
- This repository uses **named volumes with `driver_opts` and `type: none`** to back volumes by a host directory (bind semantics) while still keeping the Compose “volume” abstraction.

## Instructions

### Prerequisites
- Linux machine with **Docker** and the **docker compose** plugin installed
- A working `make`

### Configure environment
This project expects:
- `srcs/.env` containing non-secret configuration (domain, usernames, `VOLUMES_PATH`, etc.)
- `secrets/` containing password files (mounted read-only)

Key paths used by the Makefile:
- Data directory: `/home/ahmmanso/data` (created automatically by `make up`)

### Build and run
From the repository root:
- `make` or `make up`: build images and start the stack
- `make down`: stop and remove containers
- `make logs`: follow logs
- `make clean`: remove unused docker resources (system prune)
- `make fclean`: also removes `/home/ahmmanso/data`

### Access
- Website: `https://<your-domain-or-host>/` (port `443`)
- WordPress admin: `https://<your-domain-or-host>/wp-admin`

If you use a self-signed certificate, your browser will display a warning; you can add an exception for local testing.

## Resources
### Classic references
- Docker docs: https://docs.docker.com/
- Docker Compose docs: https://docs.docker.com/compose/
- Nginx docs: https://nginx.org/en/docs/
- WordPress (WP-CLI): https://developer.wordpress.org/cli/commands/
- MariaDB docs: https://mariadb.com/kb/en/documentation/
- Container networking (bridge networks): https://docs.docker.com/network/bridge/
- Volumes and bind mounts:
  - https://docs.docker.com/storage/volumes/
  - https://docs.docker.com/storage/bind-mounts/

### AI usage (required)
AI assistance was used for:
- Drafting and structuring `README.md`, `USER_DOC.md`, and `DEV_DOC.md`.
- Producing checklists and wording for the required comparisons (VM vs Docker, Secrets vs env vars, etc.).

AI was **not** used to generate the core project code (Dockerfiles, Compose, entrypoints) unless explicitly stated in commit history.
