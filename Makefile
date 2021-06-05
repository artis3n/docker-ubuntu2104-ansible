#!/usr/bin/env make

.PHONY: lint
lint:
	docker run --rm -i hadolint/hadolint hadolint --ignore DL3008 --ignore DL3013 --ignore SC2016 - < Dockerfile

.PHONY: size
size: build
	dive artis3n/docker-ubuntu2104-ansible:$${TAG:-test}

.PHONY: test
test: build
	dgoss run -it --rm --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro artis3n/docker-ubuntu2104-ansible:$${TAG:-test}
	CI=true make size

.PHONY: test-edit
test-edit: build
	dgoss edit -it --rm --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro artis3n/docker-ubuntu2104-ansible:$${TAG:-test}

.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build . -t artis3n/docker-ubuntu2104-ansible:$${TAG:-test}

.PHONY: run
run: build
	docker run -id --rm --name runner --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro artis3n/docker-ubuntu2104-ansible:$${TAG:-test}
	-docker exec -it runner /bin/sh
	docker stop runner
