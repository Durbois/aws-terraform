variable "tags" {
    type = map(string)
    default = {
        Name = "main"
        Environment = "dev"        
    }
}

variable "ips" {
    type = map(string)
    default = {
        "vpc" = "172.16.0.0/24",
        "public_subnet_a" = "172.16.0.16/28",
        "public_subnet_b" = "172.16.0.32/28",
        "private_subnet_a" = "172.16.0.48/28",
        "private_subnet_b" = "172.16.0.64/28",

    }
}

variable "amis" {
    type = map(string)
    default = {
      "linux_23" = "ami-051f7e7f6c2f40dc1"
    }
  
}