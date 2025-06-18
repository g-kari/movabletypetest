# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a MovableType CMS development environment using Docker. MovableType is a Perl-based content management system with plugin architecture, Vue.js frontend components, and comprehensive testing infrastructure.

## Common Development Commands

### Docker Environment Management
```bash
# Start the full environment
make start
# or
docker compose up -d

# Stop environment
make stop

# View logs
make logs

# Complete environment reset (deletes all data)
make reset

# Database access
make dev-mysql
# or
docker compose exec mysql mysql -u mt -p mt

# Shell access to MovableType container
make dev-shell
```

### Testing Commands
```bash
# Run Perl tests
cd mt && prove ./t ./plugins/**/t

# Run parallel tests (faster)
cd mt && prove -j4 -PMySQLPool=MT::Test::Env -It/lib ./t ./plugins/**/t

# Run JavaScript/TypeScript tests
cd mt && npm test

# Update test fixtures
cd mt && MT_TEST_UPDATE_FIXTURE=1 prove ./t ./plugins/**/t
```

### Build Commands
```bash
# Build CSS from SCSS
cd mt && npm run build-mt-css

# Build Riot.js components
cd mt && npm run build-riot

# Vue.js template development
cd themes/vue-template && npm run dev

# Build Vue.js templates for production
cd themes/vue-template && ./build.sh
# or
make vue-build
```

### Linting and Type Checking
```bash
# TypeScript type checking
cd mt && npm run svelte-check-types

# ESLint
cd mt && npm run svelte-lint

# Format code
cd mt && npm run svelte-format
```

## Architecture Overview

### Core Structure
- **mt/**: Main MovableType application (Perl-based CMS)
- **mt-static/**: Static web assets (CSS, JS, images)
- **themes/**: Custom themes including Vue.js templates
- **docker/**: Docker configuration files
- **uploads/**: User-uploaded content

### Plugin Architecture
MovableType uses a plugin system where each plugin resides in `mt/plugins/`:
- **config.yaml**: Plugin configuration and registry
- **lib/**: Perl modules implementing plugin functionality
- **tmpl/**: HTML templates for admin interface
- **t/**: Plugin-specific tests

### Key Technologies
- **Backend**: Perl with MovableType framework
- **Frontend**: jQuery, Vue.js 3, Riot.js (legacy), Bootstrap 5
- **Build Tools**: Vite (Vue.js), Node-sass (CSS), Rollup (Svelte)
- **Testing**: Perl Test::More, Vitest (JavaScript), Playwright (E2E)
- **Database**: MySQL 8.0

### Template System
MovableType uses a proprietary template language with tags like:
```html
<$mt:EntryTitle$>
<mt:Entries>...</mt:Entries>
<mt:If name="entry_flag" eq="HOLD">...</mt:If>
```

## Development Guidelines

### Plugin Development
1. Create plugin directory in `mt/plugins/YourPlugin/`
2. Define plugin in `config.yaml` with callbacks, tags, and permissions
3. Implement functionality in `lib/YourPlugin.pm` or `lib/YourPlugin/`
4. Add templates in `tmpl/` for admin interface
5. Write tests in `t/`

Refer to `MOVABLETYPE_PLUGIN_DEVELOPMENT_GUIDE.md` for comprehensive plugin development documentation.

### Vue.js Theme Development
1. Work in `themes/vue-template/src/`
2. Use `npm run dev` for development server
3. Build with `./build.sh` to deploy to `mt-static/themes/vue-template/`
4. Templates integrate Vue components via data attributes

### Testing Strategy
- **Unit Tests**: Test individual Perl modules and JavaScript components
- **Integration Tests**: Test plugin interactions and CMS workflows
- **E2E Tests**: Use Playwright for browser automation
- **Fixtures**: Use `MT_TEST_UPDATE_FIXTURE=1` when adding new test data

### Database Schema
- MovableType uses custom ORM with `MT::Object` base class
- Schema files in `schemas/` directory
- Migrations handled by upgrade system
- Test database: `mt_test` with user `mt`

## File Organization Patterns

### Perl Modules
- `lib/MT/YourClass.pm` for core classes
- `lib/YourPlugin/` for plugin modules
- Follow MovableType's callback and hook system

### Templates
- Admin templates in `tmpl/cms/` and `tmpl/admin2023/`
- Site templates in plugin `tmpl/` directories
- Use MovableType template syntax for dynamic content

### Static Assets
- CSS compiled from SCSS in `scss/` to `mt-static/css/`
- JavaScript in `src/` compiled to `mt-static/js/`
- Vue.js builds to `mt-static/themes/vue-template/assets/`

### Configuration Files
- Main config: `docker/movabletype/mt-config.cgi`
- Plugin configs: `plugins/*/config.yaml`
- Build configs: `package.json`, `vitest.config.ts`, `rollup.config.ts`

## Environment Variables and Configuration

Access environment through Docker:
- Database: mysql:3306 (user: mt, pass: movabletype, db: mt)
- Redis: redis:6379
- Web: http://localhost:8080

MovableType config in `docker/movabletype/mt-config.cgi` controls database connections, caching, and debug settings.

## Debugging and Troubleshooting

### Common Issues
- **Permission errors**: Check container volume mounts and file permissions
- **Database connection**: Verify MySQL service is running via `docker compose logs mysql`
- **Plugin errors**: Check MovableType activity log in admin interface
- **Build failures**: Clear node_modules and rebuild: `rm -rf node_modules && npm install`

### Log Files
- MovableType logs: Accessible via admin interface or container logs
- Web server: `docker compose logs movabletype`
- Database: `docker compose logs mysql`

Always test changes in the Docker environment before deployment to ensure consistency across development and production environments.