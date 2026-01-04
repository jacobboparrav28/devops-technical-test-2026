variable "project_id" {
  type        = string
}

variable "cluster_name" {
  type        = string
}

variable "region" {
  type        = string
}

variable "node_pool_name" {
  type        = string
}

variable "machine_type" {
  type        = string
}

variable "node_count" {
  type        = number
  default     = 1
}
