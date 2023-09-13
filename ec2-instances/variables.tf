variable "tags" {
  type = map(string)
  default = {
    Name        = "main"
    Environment = "dev"
  }
}

variable "vpc" {
  type    = string
  default = "172.16.0.0/24"
}

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

variable "contains" {
  type = string
  default = "public_subnet"
}

variable "amis" {
  type = map(string)
  default = {
    "linux_23" = "ami-0766f68f0b06ab145"
  }

}