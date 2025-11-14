# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Docker-based Laravel application** ("Asan Imza" - hesabatlar) with a modular architecture. The actual Laravel application lives in `../hesabatlar/` while this repository contains the Docker orchestration.

**Tech Stack:**
- Backend: Laravel 11 (PHP 8.3)
- Frontend: React 19 with Material UI (Joy)
- Build: Vite
- Database: MySQL 8.0
- Cache/Queue: Redis 7
- Queue Processing: Laravel Horizon with Supervisor (8 workers)
- Task Scheduling: Cron container

## Architecture

### Modular Structure

The application uses **nwidart/laravel-modules** for a modular monolith architecture. Each module is self-contained:

**Modules** (`../hesabatlar/Modules/`):
- Finance - Accounting and financial operations
- Integration - External service integrations
- License - License management
- Pashabank - Bank integration
- Stats - Statistics and reporting
- Tax - Tax calculations and reporting
- Telegram - Telegram bot integration

Each module contains:
- `app/` - Controllers, Services, Enums, Models
- `routes/` - Module-specific routes
- `database/` - Migrations and seeders
- `resources/` - Views and frontend assets
- `tests/` - Module tests
- `config/` - Module configuration

### React Frontend Structure

Located in `../hesabatlar/resources/js/`:
- `pages/` - Page components
- `components/` - Reusable UI components
- `services/` - API service layer
- `hooks/` - Custom React hooks
- `context/` - React context providers
- `routes/` - Route definitions
- `utils/` - Utility functions

**Path Aliases** (from vite.config.js):
```javascript
@context → /resources/js/context
@services → /resources/js/services
@pages → /resources/js/pages
@components → /resources/js/components
@routes → /resources/js/routes
@utils → /resources/js/utils
@hooks → /resources/js/hooks
```

### Docker Services

- `nginx` - Web server (ports 80, 443)
- `laravel-app` - Main PHP-FPM application
- `supervisor` - Queue worker with 8 processes (Horizon)
- `node` - For npm builds
- `composer` - For dependency management
- `artisan` - For Laravel commands
- `cron` - Scheduled tasks (runs `php artisan schedule:run`)
- `nightwatch` - Laravel Nightwatch monitoring
- `mysql` - Database (port 3306)
- `redis` - Cache/sessions/queues (port 6379)

**Important:** Application code is mounted from `../hesabatlar` into `/var/www/html` in containers.

## Common Commands

### Docker Operations

```bash
make help                  # Show all available commands
make build                 # Build all containers (no cache)
make up                    # Start all containers
make down                  # Stop all containers
make restart               # Restart all containers
make logs                  # Follow logs from all containers
make shell                 # Access PHP container shell
```

### Development Workflow

```bash
# PHP Dependencies
make composer-install      # Install dependencies
make composer-update       # Update dependencies

# Frontend Assets
make npm-install          # Install Node dependencies
make npm-dev              # Development build
make npm-prod             # Production build (removes node_modules first)

# Database
make migrate              # Run migrations
make seed                 # Run seeders
make migrate-fresh        # Fresh migration with seeding
```

### Laravel Operations

```bash
make artisan cmd="..."    # Run artisan command
make optimize             # Clear & rebuild optimization caches
make cache-clear          # Clear all caches (cache, config, route, view)
make permissions          # Fix file permissions (runs permission.sh)
make nightwatch-status    # Check Nightwatch monitoring status
```

### Queue Management

Queue workers run via Supervisor (8 processes):
- Config: `docker/confs/supervisord.conf`
- Workers: `php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600`
- Check Horizon status: `make horizon-status`
- Restart Horizon: `make horizon-restart`

### Testing

```bash
# From host
docker compose run --rm artisan test

# From within container
make shell
php artisan test                    # Run all tests
php artisan test --filter TestName  # Run specific test
php artisan dusk                    # Run browser tests
```

Test suites:
- `tests/Feature/` - Feature tests
- `tests/Unit/` - Unit tests
- `tests/Browser/` - Dusk browser tests

### Database Access

```bash
make mysql                 # Access MySQL console (needs DB credentials)
make redis-cli            # Access Redis console
```

### Deployment

```bash
make pull-project         # Full deployment: pull, migrate, optimize, build frontend
make pull-project-be      # Backend-only: pull, migrate, optimize, composer install

# Stage deployment
./stage-quick-deploy.sh   # Quick stage deployment script
```

## Key Laravel Packages

- **laravel/mcp** - Model Context Protocol integration
- **laravel/telescope** - Debugging assistant
- **laravel/nightwatch** - Application monitoring
- **laravel/pennant** - Feature flags
- **nwidart/laravel-modules** - Modular architecture
- **maatwebsite/excel** - Excel import/export
- **irazasyed/telegram-bot-sdk** - Telegram integration
- **spatie/laravel-pdf** - PDF generation

## Environment Setup

1. Copy environment files:
   ```bash
   cp .env.example .env                    # Docker environment
   cp ../hesabatlar/.env.example ../hesabatlar/.env  # Laravel environment
   ```

2. Update `.env` with database and Redis credentials

3. Build and start:
   ```bash
   make build
   make up
   ```

4. Initialize application:
   ```bash
   make composer-install
   make key-generate
   make migrate
   make npm-prod
   make permissions
   ```

## Working with Modules

When modifying modules:
1. Module routes are auto-discovered by Laravel
2. Each module has its own migrations in `Modules/{Name}/database/migrations`
3. Module service providers are in `Modules/{Name}/app/Providers`
4. Use `docker compose run --rm artisan module:...` for module commands

## File Permissions

If encountering permission issues:
```bash
make permissions          # Runs permission.sh in container
```

## Logs

Application logs:
- Laravel: `../hesabatlar/storage/logs/`
- Queue workers: `../hesabatlar/storage/logs/supervisor/worker.log`
- Cron: `../hesabatlar/storage/logs/cron/cron.log`

View container logs:
```bash
make logs                 # All containers
make cron-logs           # Cron container only
docker compose logs -f laravel-app  # Specific container
```
