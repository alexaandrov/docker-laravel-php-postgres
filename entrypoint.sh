#!/bin/bash

set -e

# Sync project dependencies with host
# cp -r /tmp/app/cache/. /app
rsync -au --delete "/tmp/app/cache/vendor/" "/app/vendor/"

# Autoloading dependencies
composer dump-autoload --no-scripts

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
