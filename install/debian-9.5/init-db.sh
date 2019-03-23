docker-compose run --rm db-oneoff pg_restore --dbname=postgres --no-acl --no-owner < initial.dump > /dev/null
