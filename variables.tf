variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tgw_asn" {
  description = "BGP ASN for Transit Gateway"
  type        = number
  default     = 64512
}

variable "vpc_id" {
  description = "VPC ID to attach to Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Transit Gateway attachment"
  type        = list(string)
}

variable "vpc_route_table_ids" {
  description = "VPC route table IDs to update"
  type        = list(string)
  default     = []
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID for default route"
  type        = string
  default     = null
}

variable "enable_dns_support" {
  description = "Enable DNS support in Transit Gateway"
  type        = bool
  default     = true
}

variable "enable_multicast" {
  description = "Enable multicast support"
  type        = bool
  default     = false
}

variable "tgw_routes" {
  description = "List of routes for Transit Gateway"
  type = list(object({
    destination_cidr = string
    attachment_id    = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_internet_gateway_routes" {
  type    = bool
  default = false
}

variable "private_route_table_ids" {
  description = "List of private route table IDs"
  type        = list(string)
  default     = []
}

variable "public_route_table_id" {
  description = "Public route table ID"
  type        = string
  default     = null
}

variable "create_vpc_routes" {
  description = "Create routes in VPC route tables to Transit Gateway"
  type        = bool
  default     = true
}
