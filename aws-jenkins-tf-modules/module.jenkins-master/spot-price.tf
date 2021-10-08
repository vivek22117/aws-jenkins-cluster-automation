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
  for_each = local.azs_instances_weights

  availability_zone = split("/", each.key)[0]
  instance_type     = split("/", each.key)[1]

  filter {
    name   = "product-description"
    values = var.product_description_list
  }
}

locals {
  price_per_unit_map = { for item in data.aws_ec2_spot_price.this : "${item.availability_zone}/${item.instance_type}" => tonumber(item.spot_price) / tonumber(lookup(local.azs_instances_weights, "${item.availability_zone}/${item.instance_type}", var.instance_weight_default)) }

  price_per_unit_list = values(local.price_per_unit_map)
  price_current_optimal = max([
    for az in local.azs_list : min([
      for key in keys(local.price_per_unit_map) : lookup(local.price_per_unit_map, key) if split("/", key)[0] == az
    ]...)
  ]...)
  price_current_min = min(local.price_per_unit_list...)
  price_current_max = max(local.price_per_unit_list...)

  spot_price_current_max         = ceil(tonumber(format("%f", local.price_current_max)) * var.normalization_modifier) / var.normalization_modifier
  spot_price_current_max_mod     = ceil(tonumber(format("%f", local.price_current_max)) * var.custom_price_modifier * var.normalization_modifier) / var.normalization_modifier
  spot_price_current_min         = ceil(tonumber(format("%f", local.price_current_min)) * var.normalization_modifier) / var.normalization_modifier
  spot_price_current_min_mod     = ceil(tonumber(format("%f", local.price_current_min)) * var.custom_price_modifier * var.normalization_modifier) / var.normalization_modifier
  spot_price_current_optimal     = ceil(tonumber(format("%f", local.price_current_optimal)) * var.normalization_modifier) / var.normalization_modifier
  spot_price_current_optimal_mod = ceil(tonumber(format("%f", local.price_current_optimal)) * var.custom_price_modifier * var.normalization_modifier) / var.normalization_modifier

}