variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "ec2_keypair" {
  type    = string
  default = "default"
}

variable "wp_title" {
  type    = string
  default = "devops"
}

variable "wp_admin_user" {
  type    = string
  default = "devops"
}

variable "wp_admin_password" {
  type    = string
  default = "devops"
}

variable "wp_admin_email" {
  type    = string
  default = "devops@gmail.com"
}
