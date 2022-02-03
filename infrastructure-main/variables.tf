variable "vpc_cidr_block" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain" {
  description = "Domain"
  type        = string
  default     = "csye7200.xyz"
}

variable "AMI_owner" {
  description = "AMI owner"
  type        = string
  default     = "582828740832"
}

variable "key_pair_name" {
  description = "key pair name"
  type        = string
  default     = "csye7200"
}

variable "kafka_ami_name" {
  description = "kafka AMI name"
  type        = string
  default     = "csye7200_kafka_*"
}

variable "zookeeper_ami_name" {
  description = "zookeeper AMI name"
  type        = string
  default     = "csye7200_zookeeper_*"
}

variable "webapp_ami_name" {
  description = "webapp AMI name"
  type        = string
  default     = "csye7200_webapp_*"
}

variable "spark_ami_name" {
  description = "spark AMI name"
  type        = string
  default     = "csye7200_spark_*"
}

variable "consumer_key" {
  description = "twitter consumer key"
  type        = string
}

variable "consumer_secret" {
  description = "twitter consumer secret"
  type        = string
}

variable "twitter_access_token" {
  description = "twitter access token"
  type        = string
}

variable "twitter_access_secret" {
  description = "twitter access secret"
  type        = string
}