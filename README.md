## Terraform Module Example

* Module should be developed to use the least amount of lines of code possible and be re-usable to easily create multiple VPCs

Three Tier Architecture (public, private & data subnets)
Exactly two Availability Zones
An `S3 VPC Endpoint`
An `Internet Gateway`
`2 NAT Gateways`
VPC Flow Logs stored in an encrypted `CloudWatch Log Group`
The subnets should meet the following specifications:

# Public Subnet:
Utilizes an `S3 VPC Endpoint` for communication to `Amazon S3`
May be open to all inbound and outbound network traffic

# Private Subnet
Utilizes an `S3 VPC Endpoint` for communication to `Amazon S3`
Should only allow traffic that supports:
Communication with a public load balancer using port 8080 (load balancer does not need to be built)
Communication with a private mySQL database (database does not need to be built)
Communication with external https, http and sFTP resources through `NAT Gateways`

# Data Subnet
Utilizes an `S3 VPC Endpoint` for communication to `Amazon S3`
Should only allow traffic that supports:

Communication with EC2 instances running in the private subnet (EC2 instances do not need to be built)




``Structure:``

`1- Config:`
    It contains a file that contains values of all variables that we are using in this project.

`2- Modules:`
    Inside modules we have 4 modules,
    cloudwatch_log_group: This module will create log group for vpc flow logs.
    iam_policy: It will create policy that we need to attach the role, this policy contains permissions for handling logs.
    iam_role: It will create role that we need to attach with vpc flow log resource.
    vpc: It will create vpc with 2 public, private and data subnets.

 `3- Network:` 
     Inside modules we have 4 files,
     Backend, main, outputs and provider 

# How to execute script:
    > Go to the network module.
    > terraform init 
    > terraform plan --var-file="../config/config.tfvars"
    > terraform apply --var-file=".    config/config.tfvars" 
