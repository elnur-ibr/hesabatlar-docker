.PHONY: help build up down restart logs shell composer npm artisan horizon test

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Docker operations
build: ## Build all containers
	docker compose build --no-cache

up: ## Start all containers
	docker compose up -d

down: ## Stop all containers
	docker compose down

restart: ## Restart all containers
	docker compose down && docker compose up -d

logs: ## Show logs from all containers
	docker compose logs -f

# Application operations
shell: ## Access PHP container shell
	docker compose exec php sh

composer: ## Install PHP dependencies
	docker compose run --rm composer install

composer-update: ## Update PHP dependencies
	docker compose run --rm composer update

npm-install: ## Install Node.js dependencies
	docker compose run --rm node npm install

npm-dev: ## Run npm development build
	docker compose run --rm node npm run dev

npm-prod: ## Run npm production build
	docker compose run --rm node npm run build

# Laravel operations
artisan: ## Run artisan commands (usage: make artisan cmd="migrate")
	docker compose run --rm artisan $(cmd)

migrate: ## Run database migrations
	docker compose run --rm artisan migrate

seed: ## Run database seeders
	docker compose run --rm artisan db:seed

migrate-fresh: ## Fresh migration with seeding
	docker compose run --rm artisan migrate:fresh --seed

key-generate: ## Generate application key
	docker compose run --rm artisan key:generate

cache-clear: ## Clear all caches
	docker compose run --rm artisan cache:clear
	docker compose run --rm artisan config:clear
	docker compose run --rm artisan route:clear
	docker compose run --rm artisan view:clear

optimize: ## Optimize application
	docker compose run --rm artisan config:cache
	docker compose run --rm artisan route:cache
	docker compose run --rm artisan view:cache

# Queue operations
horizon-status: ## Check Horizon status
	docker compose exec horizon supervisorctl status

horizon-restart: ## Restart Horizon
	docker compose exec horizon supervisorctl restart horizon

# Cron operations
cron-logs: ## View cron logs
	docker compose logs -f cron

cron-restart: ## Restart cron container
	docker compose restart cron

# Database operations
mysql: ## Access MySQL console
	docker compose exec mysql mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE)

redis-cli: ## Access Redis console
	docker compose exec redis redis-cli -a $(REDIS_PASSWORD)

# Testing
test: ## Run tests
	docker compose run --rm php ./vendor/bin/phpunit

# Setup operations
setup: ## Initial project setup
	@echo "Setting up the project..."
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env file"; fi
	docker compose up -d mysql redis
	@echo "Waiting for databases to be ready..."
	@sleep 10
	docker compose run --rm composer install
	docker compose run --rm artisan key:generate
	docker compose run --rm artisan migrate
	docker compose run --rm node npm install
	docker compose run --rm node npm run dev
	docker compose up -d
	@echo "Setup complete! Visit http://localhost"

fresh: ## Fresh installation
	docker compose down -v
	make setup