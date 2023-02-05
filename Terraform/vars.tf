
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet" {
  type = map(any)
  default = {
    subnet-a = {
      az   = "us-east-1a"
      cidr = "10.0.1.0/24"
    }
    subnet-b = {
      az   = "us-east-1b"
      cidr = "10.0.2.0/24"
    }
    subnet-c = {
      az   = "us-east-1c"
      cidr = "10.0.3.0/24"
    }
  }
}

variable "private-subnet" {
  type = map(any)
  default = {
    subnet-a = {
      az   = "us-east-1d"
      cidr = "10.0.128.0/24"
    }
    subnet-b = {
      az   = "us-east-1e"
      cidr = "10.0.144.0/24"
    }
    subnet-c = {
      az   = "us-east-1f"
      cidr = "10.0.160.0/24"
    }
  }
}

variable "inbound_ports" {
  type    = list(number)
  default = [80, 443, 22]

}

variable "keypair" {
  type      = string
  sensitive = true
}