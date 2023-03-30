#! /bin/sh

# Wait for postgres
until nc -z -v -w30 $DB_HOST $DB_PORT; do
 echo 'Waiting for Postgres...'
 sleep 1
done
echo "Postgres is up and running!"
