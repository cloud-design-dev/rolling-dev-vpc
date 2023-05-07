variable "existing_resource_group" {
  description = "Name of an existing Resource Group to use for resources. If not set, a new Resource Group will be created."
  type        = string
  default     = null
}

variable "region" {
  description = "IBM Cloud region where resources will be deployed"
  default     = "us-south"
}
