## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_igw_parameters"></a> [igw\_parameters](#input\_igw\_parameters) | IGW parameters | <pre>map(object({<br><br>    vpc_name = string<br><br>    tags = optional(map(string), {})<br><br>  }))</pre> | `{}` | no |
| <a name="input_rt_association_parameters"></a> [rt\_association\_parameters](#input\_rt\_association\_parameters) | RT association parameters | <pre>map(object({<br><br>    subnet_name = string<br><br>    rt_name = string<br><br>  }))</pre> | `{}` | no |
| <a name="input_rt_parameters"></a> [rt\_parameters](#input\_rt\_parameters) | RT parameters | <pre>map(object({<br><br>    vpc_name = string<br><br>    tags = optional(map(string), {})<br><br>    routes = optional(list(object({<br><br>      cidr_block = string<br><br>      use_igw = optional(bool, true)<br><br>      gateway_id = string<br><br>    })), [])<br><br>  }))</pre> | `{}` | no |
| <a name="input_subnet_parameters"></a> [subnet\_parameters](#input\_subnet\_parameters) | Subnet parameters | <pre>map(object({<br><br>    cidr_block = string<br><br>    vpc_name = string<br><br>    tags = optional(map(string), {})<br><br>  }))</pre> | `{}` | no |
| <a name="input_vpc_parameters"></a> [vpc\_parameters](#input\_vpc\_parameters) | VPC parameters | <pre>map(object({<br><br>    cidr_block = string<br><br>    enable_dns_support = optional(bool, true)<br><br>    enable_dns_hostnames = optional(bool, true)<br><br>    tags = optional(map(string), {})<br><br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | VPC Outputs |
