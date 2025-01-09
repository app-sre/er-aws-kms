import os
from pathlib import Path

from external_resources_io.input import parse_model, read_input_from_file

from er_aws_kms.input import AppInterfaceInput


def get_ai_input() -> AppInterfaceInput:
    """Get the AppInterfaceInput from the input file."""
    return parse_model(
        AppInterfaceInput,
        read_input_from_file(
            file_path=os.environ.get("ER_INPUT_FILE", "/inputs/input.json"),
        ),
    )


def create_tf_vars_json(
    app_interface_input: AppInterfaceInput, vars_file: str = "./module/tfvars.json"
) -> None:
    """Create the terraform vars file"""
    path = Path(vars_file)
    path.write_text(app_interface_input.data.model_dump_json(exclude_none=True))


def create_backend_tf_file(
    app_interface_input: AppInterfaceInput, backend_file: str = "./module/backend.tf"
) -> None:
    """Create the backend.tf file"""
    provision_data = app_interface_input.provision.module_provision_data
    path = Path(backend_file)
    path.write_text(
        f"""
terraform {{
  backend "s3" {{
    bucket = "{provision_data.tf_state_bucket}"
    key    = "{provision_data.tf_state_key}"
    region = "{provision_data.tf_state_region}"
    dynamodb_table = "{provision_data.tf_state_dynamodb_table}"
    profile = "external-resources-state"
  }}
}}
"""
    )


def main() -> None:
    """Main method"""
    ai_input = get_ai_input()
    create_backend_tf_file(ai_input)
    create_tf_vars_json(ai_input)


if __name__ == "__main__":
    main()
