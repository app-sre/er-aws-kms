from external_resources_io.input import AppInterfaceProvision
from pydantic import BaseModel, Field, field_validator


class KmsAppInterface(BaseModel):
    """KMS Input parameters (App-interface)"""

    identifier: str
    region: str


class Kms(KmsAppInterface):
    """KMS Input parameters (Terraform)"""

    description: str = Field(default="app-interface created KMS key")
    key_usage: str | None = None
    custom_key_store_id: str | None = None
    customer_master_key_spec: str | None = None
    policy: str | None = None
    bypass_policy_lockout_safety_check: bool | None = None
    deletion_window_in_days: int | None = None
    is_enabled: bool | None = None
    enable_key_rotation: bool | None = None
    rotation_period_in_days: int | None = None
    multi_region: bool | None = None
    tags: dict[str, str] = {}
    xls_key_id: str | None = None

    @field_validator("key_usage", mode="before")
    @classmethod
    def uppercase_key_usage(cls: type[BaseModel], value: str | None) -> str | None:
        """key_usage must be upper case"""
        if value is not None:
            return value.upper()
        return None


class AppInterfaceInput(BaseModel):
    """The input model class"""

    data: Kms
    provision: AppInterfaceProvision
