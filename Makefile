version := 0.0.1
build:
	docker build -t wizcorp/gameassets:$(version) .

push:
	docker login
	docker push wizcorp/gameassets:$(version)
