data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs_max  = 3
  azs_list = slice(data.aws_availability_zones.available.names, 0, tonumber(local.azs_max))

  instance_types = length(var.instance_types_list) == 0 ? ["t3a.small", "t2.small"] : var.instance_types_list

  instance_types_weighted_map = [for type in var.instance_types_list : { instance_type = type, weighted_capacity = var.instance_weight_default }]
  azs_instances_weights       = { for pair in setproduct(local.azs_list, local.instance_types_weighted_map) : "${pair[0]}/${pair[1].instance_type}" => pair[1].weighted_capacity }
}

data "aws_ec2_spot_price" "this" {
  for_each          = local.azs_instances_weights

  availability_zone = split("/", each.key)[0]
  instance_type     = split("/", each.key)[1]

  filter {
    name   = "product-description"
    values = var.product_description_list
  }
}

locals {
  price_per_unit_map = { for item in data.aws_ec2_spot_price.this : "${item.availability_zone}/${item.instance_type}" => tonumber(item.spot_price) / tonumber(lookup(local.azs_instances_weights, "${item.availability_zone}/${item.instance_type}", var.instance_weight_default)) }
}