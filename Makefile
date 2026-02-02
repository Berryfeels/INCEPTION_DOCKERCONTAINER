# Nome del progetto
PROJECT_NAME=Inception

# Percorso al docker-compose
COMPOSE=sudo docker compose -f ./srcs/docker-compose.yml

# Directory per i volumi
DATA_DIR=/home/stdi-pum/data

# Colori (opzionali)
GREEN=\033[0;32m
NC=\033[0m


all: up

up: create-dirs
	@echo "$(GREEN)[+] Avvio dei container...$(NC)"
	@$(COMPOSE) up -d

create-dirs:
	@echo "$(GREEN)[+] Creazione directory per i volumi...$(NC)"
	@sudo mkdir -p $(DATA_DIR)/mariadb
	@sudo mkdir -p $(DATA_DIR)/wordpress
	@sudo chown -R $(USER):$(USER) $(DATA_DIR)

build:
	@echo "$(GREEN)[+] Build dei container...$(NC)"
	@$(COMPOSE) build

start:
	@echo "$(GREEN)[-] Stop dei container...$(NC)"
	@$(COMPOSE) start

stop:
	@echo "$(GREEN)[-] Stop dei container...$(NC)"
	@$(COMPOSE) stop

down:
	@echo "$(GREEN)[-] Stop dei container...$(NC)"
	@$(COMPOSE) down

clean:
	@echo "$(GREEN)[*] Rimozione container, volumi anonimi e rete...$(NC)"
	@$(COMPOSE) down -v

fclean:
	@echo "$(GREEN)[*] Rimozione totale: container, volumi, immagini...$(NC)"
	@$(COMPOSE) down -v --rmi all --remove-orphans
	@echo "$(GREEN)[*] Removing data ...$(NC)"
	@sudo rm -rf ${DATA_DIR}

re: fclean all

logs:
	@$(COMPOSE) logs -f --tail=100

status:
	@echo "$(GREEN)[*] Stato dei container...$(NC)"
	@$(COMPOSE) ps

# Comandi
.PHONY: all up build down clean fclean re logs status
