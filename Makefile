NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/ahmmanso/data

all: up

up:
	@echo "Creating data directories..."
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@echo "Building and starting containers..."
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@echo "Stopping containers..."
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@echo "Stopping containers..."
	@docker compose -f $(COMPOSE_FILE) stop

start:
	@echo "Starting containers..."
	@docker compose -f $(COMPOSE_FILE) start

restart: down up

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	@echo "Cleaning up containers, images and networks..."
	@docker system prune -af
	@docker volume prune -f

fclean: clean
	@echo "Removing data directories..."
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up down stop start restart logs clean fclean re
