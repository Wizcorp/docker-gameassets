version := 0.2.0
build:
	docker build -t wizcorp/gameassets:$(version) .

push:
	docker login
	docker tag wizcorp/gameassets:$(version) wizcorp/gameassets:latest
	docker push wizcorp/gameassets:$(version)
	docker push wizcorp/gameassets:latest
