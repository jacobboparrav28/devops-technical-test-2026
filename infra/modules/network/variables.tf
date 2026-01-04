variable "project_id" {
    type        = string
}

variable "network_name" {
    type        = string
    default     = "default-network"
}

variable "region" {
    type        = string
    default     = "us-central1"
}

variable "subnet_cidr" {
    type        = string
}