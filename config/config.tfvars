region = "us-east-1"
profile = "profile_value"
identifier = "tf"
kms_key_arn = "arn_of_kms"

vpc_settings = {
  private_subnets = ["10.15.11.0/24","10.15.12.0/24"]
  public_subnets      = ["10.15.8.0/24","10.15.9.0/24"]
  dns_hostnames       = true
  data_subnets        = ["10.15.14.0/24","10.15.15.0/24"]
  dns_support         = true
  tenancy             = "default"
  cidr                = "10.15.8.0/21"
}

flow_log_settings = {
    enable_flow_log      = true
    traffic_type         = "ALL"
}

tags = {
  "ManagedBy" = "terraform"
  "Infra" = "v2"
}

iam_policies = {
  vpc-flow-log-policy = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
}