<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | 1.53.0-beta0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_flowlogs_bucket"></a> [flowlogs\_bucket](#module\_flowlogs\_bucket) | terraform-ibm-modules/cos/ibm | 6.5.1 |
| <a name="module_fowlogs_cos_bucket"></a> [fowlogs\_cos\_bucket](#module\_fowlogs\_cos\_bucket) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cos | v5.3.1 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git | v1.0.5 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-ibm-modules/vpc/ibm//modules/security-group | 1.1.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-ibm-modules/vpc/ibm//modules/vpc | 1.1.1 |

## Resources

| Name | Type |
|------|------|
| [ibm_is_floating_ip.bastion](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/resources/is_floating_ip) | resource |
| [ibm_is_flow_log.frontend](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/resources/is_flow_log) | resource |
| [ibm_is_instance.bastion](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/resources/is_instance) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [ibm_is_image.base](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/is_image) | data source |
| [ibm_is_ssh_key.sshkey](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/is_ssh_key) | data source |
| [ibm_is_zones.regional](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/is_zones) | data source |
| [ibm_resource_instance.cos](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/resource_instance) | data source |
| [ibm_sm_arbitrary_secret.logging_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/sm_arbitrary_secret) | data source |
| [ibm_sm_secret_group.ca_tor](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/sm_secret_group) | data source |
| [ibm_sm_secrets.secrets](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.53.0-beta0/docs/data-sources/sm_secrets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_ip_spoofing"></a> [allow\_ip\_spoofing](#input\_allow\_ip\_spoofing) | Allow IP spoofing on the bastion instance primary interface. | `bool` | `false` | no |
| <a name="input_classic_access"></a> [classic\_access](#input\_classic\_access) | Allow classic access to the VPC. | `bool` | `false` | no |
| <a name="input_default_address_prefix"></a> [default\_address\_prefix](#input\_default\_address\_prefix) | The address prefix to use for the VPC. Default is set to auto. | `string` | `"auto"` | no |
| <a name="input_existing_cos_instance"></a> [existing\_cos\_instance](#input\_existing\_cos\_instance) | The name of an existing COS instance to use for Flowlog collector buckets. | `string` | `""` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Resource group to use for all deployed resources. If not specified, a new one will be created. | `string` | n/a | yes |
| <a name="input_existing_ssh_key"></a> [existing\_ssh\_key](#input\_existing\_ssh\_key) | The name of an existing SSH key to use. If not specified, a new key will be created. | `string` | `""` | no |
| <a name="input_frontend_rules"></a> [frontend\_rules](#input\_frontend\_rules) | A list of security group rules to be added to the Frontend security group | <pre>list(<br>    object({<br>      name      = string<br>      direction = string<br>      remote    = string<br>      tcp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      udp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      icmp = optional(<br>        object({<br>          type = optional(number)<br>          code = optional(number)<br>        })<br>      )<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-vpn-udp",<br>    "remote": "0.0.0.0/0",<br>    "udp": {<br>      "port_max": 51280,<br>      "port_min": 51280<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-http",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 80,<br>      "port_min": 80<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-https",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 443,<br>      "port_min": 443<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-ssh-corvus",<br>    "remote": "64.225.48.99",<br>    "tcp": {<br>      "port_max": 22,<br>      "port_min": 22<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-ssh-malachor",<br>    "remote": "173.230.131.177",<br>    "tcp": {<br>      "port_max": 22,<br>      "port_min": 22<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-ssh-home",<br>    "remote": "136.244.50.59",<br>    "tcp": {<br>      "port_max": 22,<br>      "port_min": 22<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "icmp": {<br>      "code": 0,<br>      "type": 8<br>    },<br>    "ip_version": "ipv4",<br>    "name": "inbound-icmp",<br>    "remote": "0.0.0.0/0"<br>  },<br>  {<br>    "direction": "outbound",<br>    "ip_version": "ipv4",<br>    "name": "all-outbound",<br>    "remote": "0.0.0.0/0"<br>  }<br>]</pre> | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of an existing OS image to use. You can list available images with the command 'ibmcloud is images'. | `string` | `"ibm-ubuntu-22-04-1-minimal-amd64-3"` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | The name of an existing instance profile to use. You can list available instance profiles with the command 'ibmcloud is instance-profiles'. | `string` | `"cx2-2x4"` | no |
| <a name="input_metadata_service_enabled"></a> [metadata\_service\_enabled](#input\_metadata\_service\_enabled) | Enable the metadata service on the bastion instance. | `bool` | `true` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Project owner or identifier. This is used as a tag on all supported resources. | `string` | n/a | yes |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | Prefix to be added to all deployed resources. If none provided, one will be automatically generated. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud Region where resources will be deployed. If not specified, one will be randomly selected. To see available regions, run 'ibmcloud is regions'. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Public IP of the bastion instance. |
| <a name="output_frontend_subnet_ids"></a> [frontend\_subnet\_ids](#output\_frontend\_subnet\_ids) | The IDs of the frontend subnets. |
| <a name="output_public_gateway_ids"></a> [public\_gateway\_ids](#output\_public\_gateway\_ids) | The IDs of the public gateways. |
| <a name="output_region"></a> [region](#output\_region) | IBM Cloud Region where resources are deployed. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
