locals {
  subnet_az_cidr = {
    "us-east-1a" = "10.0.1.0/24",
    "us-east-1b" = "10.0.2.0/24",
    "us-east-1c" = "10.0.3.0/24",
  }
  kafka_index = toset(["0", "1", "2"])
}