# Description: Data sources for the module

data "ibm_is_image" "base" {
  name = var.image_name
}

data "ibm_is_ssh_key" "sshkey" {
  name = var.existing_ssh_key
}

# Pull in the zones in the region
data "ibm_is_zones" "regional" {
  region = var.region
}


data "ibm_resource_instance" "cos" {
  name              = var.existing_cos_instance
  location          = "global"
  resource_group_id = module.resource_group.resource_group_id
  service           = "cloud-object-storage"
}

data "ibm_sm_secret_group" "ca_tor" {
  instance_id     = var.sm_instance_guid
  region          = "us-south"
  secret_group_id = var.secret_group_id
}


data "ibm_sm_secrets" "secrets" {
  depends_on  = [data.ibm_sm_secret_group.ca_tor]
  instance_id = var.sm_instance_guid
  region      = "us-south"
  groups      = data.ibm_sm_secret_group.ca_tor.secret_group_id
}

data "ibm_sm_arbitrary_secret" "logging_key" {
  depends_on  = [data.ibm_sm_secrets.secrets]
  instance_id = var.sm_instance_guid
  region      = "us-south"
  secret_id   = local.logging_secret[0]
}