variable "project_id" {
  type        = string
}

variable "region" {
    type        = string
    default     = "us-central1"
}

variable "artifact_registry_repo" {
  type = string
}