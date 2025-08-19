git reset --hard && git pull \
&& docker-compose run --rm composer install \
&& docker-compose run --rm artisan migrate --force \
&& docker-compose run --rm artisan db:seed --class DeploymentSeeder \
&& docker-compose run --rm artisan settings:check \
&& docker-compose run --rm artisan optimize:clear \
&& docker-compose run --rm artisan optimize \
&& docker-compose exec php sh permission.sh \
&& docker-compose run --rm artisan horizon:terminate \
&& docker-compose run --rm artisan telescope:publish --ansi \
&& docker-compose run --rm artisan horizon:publish --ansi

#for windows
#php artisan migrate --force && php artisan db:seed --class DeploymentSeeder && php artisan settings:check && php artisan optimize:clear