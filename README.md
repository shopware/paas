# Shopware for Platform.sh

This template builds Shopware on Platform.sh using Composer. To get started on Platform.sh, please visit https://docs.platform.sh/

## Services

-   PHP 7.4
-   MariaDB 10.5
-   Redis 6.0

## Post-install

1. The first time the site is deployed, Shopware's command line installer will run and initialize Shopware. It will not run again unless the `installer/installed` is removed. (Do not remove that file unless you want the installer to run on the next deploy!)

2. The installer will create an administrator account with username/password `admin`/`shopware`. **You need to change this password immediately. Not doing so is a security risk**.

## Customizations

This project is built on the [shopware/production](https://github.com/shopware/production) repo. All plugins MUST be installed through Composer. The in-browser plugin manager will not work as the disk is read-only.

The following changes have been made relative to a plain Shopware production project. If using this project as a reference for your own existing project, replicate the changes below to your project.

-   The `.platform.app.yaml`, `.platform/services.yaml`, and `.platform/routes.yaml` files have been added. These provide Platform.sh-specific configuration and are present in all projects on Platform.sh. You may customize them as you see fit.
-   An additional Composer library, [`platformsh/symfonyflex-bridge`](https://github.com/platformsh/symfonyflex-bridge), has been added. It is a bridge library which connects Symfony Flex-based application to Platform.sh.
-   The [`platformsh-env.php`](platformsh-env.php) file will map Platform.sh environment variables to the enviroment variables expected by Shopware. It is auto-included from `composer.json` as part of the autoload process.
-   Configuration has been added to use Redis for cache and sessions, see [`config/packages/framework.yaml`](config/packages/framework.yaml)
-   [`config/packages/shopware.yaml`](config/packages/shopware.yaml) has been updated to disable auto update
-   [`config/packages/shopware.yaml`](config/packages/shopware.yaml) has been updated to disable the admin worker (a message consumer is started instead, see the `workers` section in [`.platform.app.yaml`](.platform.app.yaml))

## Stateless Builds

This build uses ["Building without Database"](https://developer.shopware.com/docs/guides/hosting/installation-updates/deployments/build-w-o-db).

To support the stateless build for the theme, the theme-config is checked into git for it being available during the build process (an alternative is to store it on an external object storage).

To update the config

> IMPORTANT: You have to run this once after the first install, otherwise the Frontend will not load css/js files correctly.

-   Dump the theme config e.g. via `platform ssh -A app 'bin/console theme:dump'` (this will generate new config files in files/theme config)
-   Download the the generated theme config via `platform mount:download --mount 'files' --target 'files' -A app`
-   You can then remove the old files and add the new files to git (`git add files/theme-config`, `git commit -m 'update theme config'`)
-   Commit and Push for a redeployment (`git push`)

## Optional additions

### Elasticsearch

1. Add Elasticsearch to [`.platform/services.yaml`](.platform/services.yaml)
2. Add a relationship for it in [`.platform.app.yaml`](.platform.app.yaml)
3. Follow the steps mentioned in the [documentation](https://developer.shopware.com/docs/guides/hosting/infrastructure/elasticsearch#activating-and-first-time-indexing) to prepare your instance. `SHOPWARE_ES_HOSTS`, `SHOPWARE_ES_INDEXING_ENABLED` and `SHOPWARE_ES_INDEX_PREFIX` are set in [`platformsh-env.php`](platformsh-env.php).
4. If all is good, you can enable via `SHOPWARE_ES_ENABLED` (either uncomment in [`platformsh-env.php`](platformsh-env.php) or add as a [`variable`](https://docs.platform.sh/development/variables.html))

### RabbitMQ

1. Add RabbitMQ in [`.platform/services.yaml`](.platform/services.yaml)
2. Add a relationship for it in [`.platform.app.yaml`](.platform.app.yaml)
3. Push to Platform.sh (so RabbitMQ is provisioned)
4. For RabbitMQ to work, you need to manually add a queue named `shopware-queue` and a `messages` exchange. To do this you can e.g. use the platform CLI to open a tunnel (`ssh -L 15672:rabbitmqqueue.internal:15672 $(platform ssh --pipe -A app)`) and open the UI via `http://localhost:15672/`. You can get the credentials via `platform relationships`. `RABBITMQ_URL` is set in [`platformsh-env.php`](platformsh-env.php).
5. `composer require enqueue/amqp-bunny`
6. Uncomment [`config/packages/enqueue.yaml`](config/packages/enqueue.yaml)

## References

-   [Shopware](https://www.shopware.com/en/)
-   [PHP on Platform.sh](https://docs.platform.sh/languages/php.html)
