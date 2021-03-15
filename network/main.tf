module "vpc" {
  source = "../modules/vpc"
  vpc_settings       = var.vpc_settings
  flow_log_settings  = var.flow_log_settings
  identifier         = var.identifier
  region             = var.region
  log_destination    = module.log_group.output.log_group.arn
  iam_role_arn       = module.vpc_flow_logs_role.output.role.arn
  tags               = var.tags
}

module "log_group" {
  source = "../modules/cloudwatch_log_group"
  identifier  = "${var.identifier}-vpc-flow-log-group"
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

module "vpc_flow_logs_policy" {
  source = "../modules/iam_policy"
  identifier             = var.identifier
  policy                 = var.iam_policies.vpc-flow-log-policy
  tags                   = var.tags
}

module "vpc_flow_logs_role" {
  source = "../modules/iam_role"
  iam_policies_to_attach = [module.vpc_flow_logs_policy.output.policy.arn]
  identifier             = var.identifier
  tags                   = var.tags
}