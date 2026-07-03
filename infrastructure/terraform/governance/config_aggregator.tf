###############################################################
# AWS Config Aggregator
###############################################################

module "config_aggregator" {

  source = "../modules/config-aggregator"

  aggregator_name = local.config_aggregator_name

  organization_aggregation = true

  tags = local.common_tags

}