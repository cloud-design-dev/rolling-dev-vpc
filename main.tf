locals {
  deploy_date    = formatdate("YYYYMMDD", timestamp())
  prefix         = "rtlab-${random_string.prefix.result}-${local.deploy_date}"
  zones          = length(data.ibm_is_zones.regional.zones)
  secrets        = [for secret in data.ibm_sm_secrets.secrets.secrets : secret if secret.name == "ca-tor-logging-key"]
  logging_secret = [for secret in local.secrets : secret.id if secret.name == "ca-tor-logging-key"]
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.region}-${zone + 1}"
    }
  }
  tags = [
    "owner:ryantiffany",
    "project:${local.prefix}",
    "deploydate:${local.deploy_date}"
  ]
}

resource "random_string" "prefix" {
  length  = 4
  special = false
  numeric = false
  upper   = false
}

module "resource_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

module "vpc" {
  source                      = "terraform-ibm-modules/vpc/ibm//modules/vpc"
  version                     = "1.1.1"
  create_vpc                  = true
  vpc_name                    = "${local.project_prefix}-vpc"
  resource_group_id           = module.resource_group.id
  classic_access              = false
  default_address_prefix      = "auto"
  default_network_acl_name    = "${local.project_prefix}-vpc-default-network-acl"
  default_security_group_name = "${local.project_prefix}-vpc-default-security-group"
  default_routing_table_name  = "${local.project_prefix}-vpc-default-routing-table"
  vpc_tags                    = local.tags
  locations                   = [local.vpc_zones.0.zone, local.vpc_zones.1.zone, local.vpc_zones.2.zone]
  subnet_name                 = "${local.project_prefix}-frontend-subnet"
  number_of_addresses         = "128"
  create_gateway              = true
  public_gateway_name         = "${local.project_prefix}-vpc-pub-gw"
  gateway_tags                = local.tags
}

module "security_group" {
  source                = "terraform-ibm-modules/vpc/ibm//modules/security-group"
  version               = "1.1.1"
  create_security_group = true
  name                  = "${local.prefix}-frontend-sg"
  vpc_id                = module.vpc.vpc_id[0]
  resource_group_id     = module.resource_group.resource_group_id
  security_group_rules  = local.frontend_rules
}

module "fowlogs_cos_bucket" {

  source                   = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=v5.3.1"
  bucket_name              = "${local.prefix}-${substr(module.vpc.subnet_ids[count.index], 1, 6)}-bucket"
  create_cos_instance      = false
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  encryption_enabled       = false
  existing_cos_instance_id = data.ibm_resource_instance.cos.id
}


module "flowlogs_bucket" {
  count               = length(module.vpc.subnet_ids)
  source              = "terraform-ibm-modules/cos/ibm"
  version             = "6.5.1"
  bucket_name         = "${local.project_prefix}-${local.vpc_zones[count.index].zone}-collector-bucket"
  create_cos_instance = false
  resource_group_id   = module.resource_group.resource_group_id
  region              = var.region
  # encryption_enabled       = false
  existing_cos_instance_id = data.ibm_resource_instance.cos.id
}

resource "ibm_is_flow_log" "frontend" {
  depends_on     = [module.flowlogs_bucket]
  count          = length(module.vpc.subnet_ids)
  name           = "${local.project_prefix}-${local.vpc_zones[count.index].zone}-collector"
  target         = module.vpc.subnet_ids[count.index]
  active         = true
  storage_bucket = module.flowlogs_bucket[count.index].bucket_name[0]
}

resource "ibm_is_instance" "bastion" {
  name                     = "${local.prefix}-bastion"
  vpc                      = module.vpc.vpc_id[0]
  image                    = data.ibm_is_image.base.id
  profile                  = var.instance_profile
  resource_group           = module.resource_group.resource_group_id
  metadata_service_enabled = var.metadata_service_enabled

  boot_volume {
    name = "${local.prefix}-boot-volume"
  }

  primary_network_interface {
    subnet            = module.vpc.subnet_ids[0]
    allow_ip_spoofing = var.allow_ip_spoofing
    security_groups   = [module.security_group.security_group_id[0]]
  }
  # Need to strip out logging and monitoring key from installer script 
  # Use installer for consul, nomad, vault  
  user_data = templatefile("${path.module}/init.tftpl", { logdna_ingestion_key = module.logging.logdna_ingestion_key, region = var.region, vpc_tag = "vpc:${local.prefix}-vpc" })
  zone      = local.vpc_zones[0].zone
  keys      = [data.ibm_is_ssh_key.sshkey.id]
  tags      = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_floating_ip" "bastion" {
  name           = "${local.prefix}-bastion-public-ip"
  resource_group = module.resource_group.resource_group_id
  target         = ibm_is_instance.bastion.primary_network_interface[0].id
  tags           = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}