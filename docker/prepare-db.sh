#! /bin/sh

# If the database exists, migrate. Otherwise setup (create and migrate)
bin/rails db:migrate 2>/dev/null || bin/rails db:create db:migrate db:seed
# bundle exec rake db:drop db:create db:migrate db:seed 2>/dev/null || bundle exec rake db:drop db:create db:migrate db:seed
echo "Donee!"
