variable "region" {
  description = "deployment region"
  type        = string
  default     = "us-east-1"
}

variable "ami" {
  description = "ami-id"
  type        = string
  default     = "ami-0bef6cc322bfff646"
}


variable "apachebstp" {
  description = "apchebootstrap"
  type        = string
  default     = <<-EOF

  #!/bin/bash
  sudo yum update -y #command to update all packages available
  sudo yum install -y httpd #to install apache
  sudo systemctl start httpd #to start apache server
  sudo systemctl enable httpd #to start automatically on boot
  sudo systemctl restart httpd #to restart apache server
  EOF
}

variable "wk21s3" {
  description = "s3 bucket"
  type        = string
  default     = "wk21bucket"
}