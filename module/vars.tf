# 1. Variables used by App-Interface. Not part of the resources definition.
variable "identifier" {
  description = "The resource identifier"
  type        = string
}

variable "region" {
  description = "The region where the KMS key will be created"
  type        = string
  default     = "us-east-1"
}

# 2.- Variables directly used by resources
# Variable for the key description
variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "app-interface created KMS key"
}

# Variable for the key usage
variable "key_usage" {
  description = "Usage of the KMS key (ENCRYPT_DECRYPT or SIGN_VERIFY)"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

# Custom key store ID
variable "custom_key_store_id" {
  description = "ID of the KMS Custom Key Store where the key will be stored instead of KMS (eg CloudHSM)."
  type        = string
  default     = null
}

# Custom key store ID
variable "customer_master_key_spec" {
  description = "ID of the KMS Custom Key Store where the key will be stored instead of KMS (eg CloudHSM)."
  type        = string
  default     = null
}

# Variable for the customer master key (CMK) policy
variable "policy" {
  description = "The key policy in JSON format"
  type        = string
  default     = null
}

# Bypass policy lockout safety check
variable "bypass_policy_lockout_safety_check" {
  description = "Specifies whether to bypass the key policy lockout safety check. Setting this to true increases the risk of the KMS key becoming unmanageable."
  type        = bool
  default     = null
}

# Deletion window in days
variable "deletion_window_in_days" {
  description = "Specifies the waiting period, in days, before deleting the KMS key."
  type        = number
  default     = null
}

# is_enabled
variable "is_enabled" {
  description = "Specifies whether the key is enabled."
  type        = bool
  default     = true
}


# Variable for enabling key rotation
variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = false
}

# Variable for enabling key rotation
variable "rotation_period_in_days" {
  description = "Custom period of time between each rotation date. Must be a number between 90 and 2560."
  type        = number
  default     = null
}


# Multi-Region key
variable "multi_region" {
  description = "Specifies whether the KMS key is a multi-Region or single-Region key."
  type        = bool
  default     = false
}


# Variable for tags
variable "tags" {
  description = "Tags to assign to the KMS key"
  type        = map(string)
  default     = {}
}

variable "xls_key_id" {
  description = "Identifies the external key that serves as key material for the KMS key in an external key store."
  type        = string
  default     = null
}
