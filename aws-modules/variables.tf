variable "subnets" {
  type = map(object({
    ip = string,
    az = string
  }))
  default = {
    "public_subnet_a"  = {
      ip = "172.16.0.16/28",
      az = "eu-central-1a"
    },
    "public_subnet_b"  = {
      ip = "172.16.0.32/28",
      az = "eu-central-1b"
    },
    "private_subnet_a" = {
      ip = "172.16.0.48/28",
      az = "eu-central-1a"
    },
    "private_subnet_b" = {
      ip = "172.16.0.64/28",
      az = "eu-central-1b"
    },

  }
}

variable "public_substr" {
  type = string
  default = "public_subnet"
}

variable "private_substr" {
  type = string
  default = "private_subnet"
}

variable "vpc" {
  type    = string
  default = "172.16.0.0/24"
}