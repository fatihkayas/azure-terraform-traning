variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "grafana-rg"
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "public_key_path" {
  description = "The path to the public key file"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  default     = "" # Default left empty to be set from environment variable
}

