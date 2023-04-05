# README

It is a sample e-learning application for creating learning paths and courses.

## Features

* Rails 6
* Ruby 2.6.5
* Dockerfile and Docker Compose configuration
* PostgreSQL database
* Rspec & Factorybot
* GitHub Actions for
  * tests
  * security checks
  * Rubocop for linting(upcoming)
* I18n

## Assumptions

* If a talent is assigned to a learning path, so I am going to search to the first available course bec. may the talent took the first course before. and same concept when the talent completed the current course
so I assign to him the next available one by the same way.
* We can't delete a course which is already in-progress with any user in any learning path. (Discuss during the interview)

## Requirements

Please ensure you have docker & docker-compose

https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/How-to-install-Docker-and-docker-compose-on-Ubuntu

https://dockerlabs.collabnix.com/intermediate/workshop/DockerCompose/How_to_Install_Docker_Compose.html

Check your docker compose version with:
```
% docker compose version
Docker Compose version v1.27.4
```

## Initial setup
```
$ cp .env.example .env
$ cd docker
$ docker-compose --env-file ../.env build
```

## Running the Rails app
```
$ docker-compose --env-file ../.env up
```
## Running the Rails console
When the app is already running with `docker-compose` up, attach to the container:
```
$ docker-compose exec app bin/rails c
```
When no container running yet, start up a new one:
```
$ docker-compose run --rm app bin/rails c
```
## Running tests
```
$ docker-compose run --rm app bin/rspec
```

## Postman script
```
There is a postman script that contains the whole scenario.
you can find it in postman folder.
```

## Author

**Mohamed Nabil**

- <https://www.linkedin.com/in/mohamed-nabil-a184125b>
- <https://github.com/mohamednabil00000>
- <https://leetcode.com/mohamednabil00000/>
