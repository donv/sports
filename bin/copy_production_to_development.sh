#!/bin/bash -el

HEROKU_APP=kubosch-sports
DB_NAME=sports_development

echo "Disconnecting clients"
set +e
echo "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity
    WHERE datname = '$DB_NAME' AND state = 'idle';" | psql $DB_NAME
set -e

echo "Re-creating database"
dropdb --if-exists $DB_NAME
bin/rake db:create

echo "Transferring database"
time pg_dump `heroku config:get --app=${HEROKU_APP} DATABASE_URL` | psql $DB_NAME

export JRUBY_OPTS=--dev
RAILS_ENV=development bundle exec rake db:migrate
