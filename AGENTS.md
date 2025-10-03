# Agent.md

This file provides guidance to AI agents when working with code in this
repository.

## Overview

The `er-aws-kms` module is an External Resources v2 (ERv2) module for managing
AWS KMS keys through App-Interface. It provides a Python-based interface for
generating Terraform configurations to create and manage KMS keys in AWS.

## Development Commands

```bash
# Set up local development environment
make dev

# Format code (linting and formatting)
make format

# Lock Terraform providers for multiple platforms
make providers-lock

# Run all code tests (linting, type checking, unit tests)
make code_tests

# Run Terraform format validation
make terraform_tests

# Run all tests (code + terraform)
make test

# Build test container image
make build_test

# Build production container image
make build
```

## Capabilities

- Generate Terraform configurations for KMS key creation
- Manage KMS key properties (description, usage, rotation, etc.)
- Handle multi-region key configurations
- Apply proper tagging strategies

## Core Components

- `generate_tf_files()`: Main entry point for generating Terraform files
- `create_backend_tf_file()`: Creates Terraform backend configuration
- `create_tf_vars_json()`: Generates Terraform variables JSON
- `get_ai_input()`: Retrieves and parses App-Interface input
- `parse_model()`: Validates input against Pydantic models
- Field validators for data transformation (e.g., uppercase key usage)

## Input Validation

**Purpose**: Validates and processes input data from App-Interface

**Capabilities**:

- Parse and validate App-Interface input data
- Transform input data to proper formats
- Validate KMS key parameters
- Ensure data type consistency

## Configuration Parameters

Configuration parameters (specified by input.json):

- `identifier`: Resource identifier
- `region`: AWS region for key creation
- `description`: Key description
- `key_usage`: Key usage (ENCRYPT_DECRYPT or SIGN_VERIFY)
- `custom_key_store_id`: Custom key store ID
- `customer_master_key_spec`: Customer master key specification
- `policy`: Key policy in JSON format
- `bypass_policy_lockout_safety_check`: Policy lockout safety check bypass
- `deletion_window_in_days`: Key deletion window
- `is_enabled`: Key enabled status
- `enable_key_rotation`: Key rotation enablement
- `rotation_period_in_days`: Custom rotation period
- `multi_region`: Multi-region key flag
- `tags`: Key tags
- `xls_key_id`: External key store key ID

## Dependencies

- **external-resources-io**: Core ERv2 framework
- **pydantic**: Data validation and serialization
- **terraform**: Infrastructure as Code
- **aws**: Cloud provider

## Usage

The module works together with App-Interface to process input and generate
Terraform configurations:

```bash
# For testing and development purposes, there is a qontract-cli command to
# generate the `input.json` data for a specific resource.
qontract-cli --config=... external-resources get-input <provision_provider> \
  <provisioner> <provider> <identifier>

# Input format (input.json)
{
    "data": {
        "identifier": "my-kms-key",
        "region": "us-east-1",
        "key_usage": "encrypt_decrypt",
        "is_enabled": true,
        "tags": {
            "environment": "production",
            "app": "my-app"
        }
    },
    "provision": {
        "provision_provider": "aws",
        "provisioner": "my-provisioner",
        "provider": "kms",
        "identifier": "my-kms-key",
        "target_cluster": "my-cluster",
        "target_namespace": "my-namespace",
        "target_secret_name": "my-kms-secret",
        "module_provision_data": {
            "tf_state_bucket": "my-state-bucket",
            "tf_state_region": "us-east-1",
            "tf_state_dynamodb_table": "my-lock-table",
            "tf_state_key": "aws/my-cluster/kms/my-kms-key/terraform.tfstate"
        }
    }
}

# Add the generated data to ./inputs/input.json

# Generate Terraform configuration
generate-tf-config

# Go to module dir which contains all the created terraform config
cd ./module

# Check the kms resource using terraform plan command
terraform plan -out plan.out

# Create kms resource using terraform apply command
terraform apply plan.out
```
