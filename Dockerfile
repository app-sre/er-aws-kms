FROM quay.io/redhat-services-prod/app-sre-tenant/er-base-terraform-main/er-base-terraform-main:tf-1.6.6-v0.1.0-1 AS base
# keep in sync with pyproject.toml
LABEL konflux.additional-tags="0.1.0"

FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:0.5.24@sha256:2381d6aa60c326b71fd40023f921a0a3b8f91b14d5db6b90402e65a635053709 /uv /bin/uv

ENV TF_PROVIDER_AWS_VERSION="5.82.2"
ENV TF_PLUGIN_CACHE="${HOME}/.terraform.d/plugin-cache"
ENV TF_PROVIDER_AWS_PATH="${TF_PLUGIN_CACHE}/registry.terraform.io/hashicorp/aws/${TF_PROVIDER_AWS_VERSION}/linux_amd64"

RUN mkdir -p ${TF_PROVIDER_AWS_PATH} && \
    curl -sfL https://releases.hashicorp.com/terraform-provider-aws/${TF_PROVIDER_AWS_VERSION}/terraform-provider-aws_${TF_PROVIDER_AWS_VERSION}_linux_amd64.zip \
    -o /tmp/package-aws-${TF_PROVIDER_AWS_VERSION}.zip && \
    unzip /tmp/package-aws-${TF_PROVIDER_AWS_VERSION}.zip -d ${TF_PROVIDER_AWS_PATH}/ && \
    rm /tmp/package-aws-${TF_PROVIDER_AWS_VERSION}.zip

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
COPY module ./module

# Sync the project
RUN uv sync --frozen --no-group dev

FROM base AS prod
# get cdktf providers
COPY --from=builder ${TF_PLUGIN_CACHE_DIR} ${TF_PLUGIN_CACHE_DIR}
# get our app with the dependencies
COPY --from=builder ${APP} ${APP}

ENV \
    # Use the virtual environment
    PATH="${APP}/.venv/bin:${PATH}"

FROM prod AS test
COPY --from=ghcr.io/astral-sh/uv:0.5.24@sha256:2381d6aa60c326b71fd40023f921a0a3b8f91b14d5db6b90402e65a635053709 /uv /bin/uv

# install test dependencies
RUN uv sync --frozen

COPY Makefile ./
COPY tests ./tests

RUN make test

# Empty /tmp again because the test stage might have created files there, e.g. JSII_RUNTIME_PACKAGE_CACHE_ROOT
# and we want to run this test image in the dev environment
RUN rm -rf /tmp/*
