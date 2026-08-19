variable "aws_region" {
  description = "AWS region for MLOps infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"

  validation {
    condition = contains([
      "t3.micro",
      "t3.small",
      "t3.medium"
    ], var.instance_type)

    error_message = "Only t3.micro, t3.small and t3.medium are allowed."
  }
}

variable "disk_size" {
  description = "Root EBS disk size in GB"
  type        = number
  default     = 60
}

variable "project_name" {
  description = "Project name used for AWS resource tags"
  type        = string
  default     = "mlops-foundations"
}
