FROM quay.io/redhat-services-prod/app-sre-tenant/er-base-terraform-main/er-base-terraform-main:0.3.8-2@sha256:e757c762403e112f832ac5c788f6e25f222c66b7633296a8ed4546ca943a18b7 AS base
# keep in sync with pyproject.toml
LABEL konflux.additional-tags="0.2.2"

FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:0.7.10@sha256:8cb222a0ab487c56ca1368c9f6c221b7fb008a0e4bb81ee623ef1f9d7b08fb6c /uv /bin/uv

# Python and UV related variables
ENV \
    # compile bytecode for faster startup
    UV_COMPILE_BYTECODE="true" \
    # disable uv cache. it doesn't make sense in a container
    UV_NO_CACHE=true \
    UV_NO_PROGRESS=true \
    TERRAFORM_MODULE_SRC_DIR="${APP}/module"

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
COPY module ./module

# Get the terraform providers
RUN terraform-provider-sync

FROM builder AS test
# install test dependencies
RUN uv sync --frozen

COPY Makefile ./
COPY tests ./tests

RUN make test


FROM builder AS prod
# get cdktf providers
COPY --from=builder ${TF_PLUGIN_CACHE_DIR} ${TF_PLUGIN_CACHE_DIR}
# get our app with the dependencies
COPY --from=builder ${APP} ${APP}


ENV \
    VIRTUAL_ENV="${APP}/.venv" \
    PATH="${APP}/.venv/bin:${PATH}"
