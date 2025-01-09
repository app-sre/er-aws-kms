from er_aws_kms.input import Kms


def test_key_usage_uppercase() -> None:
    """Test key_usage is upper case"""
    model = Kms.model_validate({
        "identifier": "test",
        "region": "us-east-1",
        "key_usage": "encrypt-decrypt",
    })
    assert model.key_usage == "ENCRYPT-DECRYPT"
