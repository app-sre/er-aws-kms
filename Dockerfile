FROM quay.io/redhat-services-prod/app-sre-tenant/er-base-terraform-main/er-base-terraform-main:tf-1.6.6-v0.2.0-1 AS base
# keep in sync with pyproject.toml
LABEL konflux.additional-tags="0.2.0"

FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:0.5.25@sha256:a73176b27709bff700a1e3af498981f31a83f27552116f21ae8371445f0be710 /uv /bin/uv

# Python and UV related variables
ENV \
    # compile bytecode for faster startup
    UV_COMPILE_BYTECODE="true" \
    # disable uv cache. it doesn't make sense in a container
    UV_NO_CACHE=true \
    UV_NO_PROGRESS=true

COPY pyproject.toml uv.lock ./
# Test lock file is up to date
RUN uv lock --locked
# Install dependencies
RUN uv sync --frozen --no-group dev --no-install-project --python /usr/bin/python3

# the source code
COPY README.md ./
COPY er_aws_kms ./er_aws_kms

# Sync the project
RUN uv sync --frozen --no-group dev

# Copy the module directory and set 777 permissions.
USER 0
COPY module ./module
RUN chmod 777 ./module

# Get the terraform providers
RUN \
    mkdir /tmp/tf_init/ \
    && cp module/versions.tf /tmp/tf_init \
    && terraform -chdir=/tmp/tf_init init

FROM base AS prod
# get cdktf providers
COPY --from=builder ${TF_PLUGIN_CACHE_DIR} ${TF_PLUGIN_CACHE_DIR}
# get our app with the dependencies
COPY --from=builder ${APP} ${APP}


ENV \
    # Use the virtual environment
    PATH="${APP}/.venv/bin:${PATH}"

FROM prod AS test
COPY --from=ghcr.io/astral-sh/uv:0.5.25@sha256:a73176b27709bff700a1e3af498981f31a83f27552116f21ae8371445f0be710 /uv /bin/uv

# install test dependencies
RUN uv sync --frozen

COPY Makefile ./
COPY tests ./tests

RUN make test

# Empty /tmp again because the test stage might have created files there, e.g. JSII_RUNTIME_PACKAGE_CACHE_ROOT
# and we want to run this test image in the dev environment
RUN rm -rf /tmp/*
