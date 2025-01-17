CONTAINER_ENGINE ?= $(shell which podman >/dev/null 2>&1 && echo podman || echo docker)

.PHONY: format
format:
	uv run ruff check
	uv run ruff format

.PHONY: image_tests
image_tests:
	# test /tmp must be empty
	[ -z "$(shell ls -A /tmp)" ]

.PHONY: code_tests
code_tests:
	uv run ruff check --no-fix
	uv run ruff format --check
	uv run mypy
	uv run pytest -vv --cov=er_aws_kms --cov-report=term-missing --cov-report xml

.PHONY: test
test: image_tests code_tests

.PHONY: build
build:
	$(CONTAINER_ENGINE) build --progress plain -t er-aws-kms:test .

.PHONY: dev
dev:
	# Prepare local development environment
	uv sync
