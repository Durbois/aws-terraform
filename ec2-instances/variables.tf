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
        "public-subnet-a" = "172.16.0.16/28",
        "public-subnet-b" = "172.16.0.32/28",
        "private-subnet-a" = "172.16.0.48/28",
        "private-subnet-b" = "172.16.0.64/28",

    }
}