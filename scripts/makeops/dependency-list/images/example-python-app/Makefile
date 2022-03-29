build:
	docker build --rm \
		--file Dockerfile \
		--tag makeops/dependency-list/python-app:example \
		.

clean:
	docker image rm --force makeops/dependency-list/python-app:example 2> /dev/null ||:
