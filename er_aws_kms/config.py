import os

from external_resources_io.input import (
    create_backend_tf_file,
    create_tf_vars_json,
    parse_model,
    read_input_from_file,
)

from er_aws_kms.input import AppInterfaceInput


def get_ai_input() -> AppInterfaceInput:
    """Get the AppInterfaceInput from the input file."""
    return parse_model(
        AppInterfaceInput,
        read_input_from_file(
            file_path=os.environ.get("ER_INPUT_FILE", "/inputs/input.json"),
        ),
    )


def generate_tf_files() -> None:
    """Main method"""
    ai_input = get_ai_input()
    create_backend_tf_file(ai_input.provision)
    create_tf_vars_json(ai_input.data)
