# Nome del progetto
PROJECT_NAME=Inception

# Percorso al docker-compose
COMPOSE=docker compose -f ./srcs/docker-compose.yml

# Colori (opzionali)
GREEN=\033[0;32m
NC=\033[0m

# Comandi
.PHONY: all up build down clean fclean re logs

all: up

up:
	@echo "$(GREEN)[+] Avvio dei container...$(NC)"
	@$(COMPOSE) up -d

build:
	@echo "$(GREEN)[+] Build dei container...$(NC)"
	@$(COMPOSE) build

down:
	@echo "$(GREEN)[-] Stop dei container...$(NC)"
	@$(COMPOSE) down

clean:
	@echo "$(GREEN)[*] Rimozione container, volumi anonimi e rete...$(NC)"
	@$(COMPOSE) down -v

fclean:
	@echo "$(GREEN)[*] Rimozione totale: container, volumi, immagini...$(NC)"
	@$(COMPOSE) down -v --rmi all --remove-orphans

re: fclean all

logs:
	@$(COMPOSE) logs -f --tail=100
