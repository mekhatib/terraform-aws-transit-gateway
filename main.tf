# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description                     = "${var.project_name}-${var.environment} Transit Gateway"
  amazon_side_asn                = var.tgw_asn
  dns_support                    = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support              = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  multicast_support              = var.enable_multicast ? "enable" : "disable"
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-tgw"
    }
  )
}

# Transit Gateway VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids                                      = var.subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = var.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-tgw-vpc-attach"
    }
  )
}

# Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-tgw-rtb"
    }
  )
}

# Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "main" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "routes" {
  for_each = { for idx, route in var.tgw_routes : idx => route }
  destination_cidr_block         = each.value.destination_cidr
  transit_gateway_attachment_id  = each.value.attachment_id == "vpc" ? aws_ec2_transit_gateway_vpc_attachment.main.id : each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Update VPC Route Tables to route through TGW - FINAL FIX: No dynamic dependencies
# Create routes only when explicitly enabled and route table IDs are provided as static values
resource "aws_route" "private_to_tgw" {
  # Use length() only on variables passed directly to the module, not computed values
  count = var.create_vpc_routes && length(var.private_route_table_ids) > 0 ? length(var.private_route_table_ids) : 0
  
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}

# Only create public route if public_route_table_id is explicitly provided and not empty
resource "aws_route" "public_to_tgw" {
  count = var.create_vpc_routes && var.public_route_table_id != null && var.public_route_table_id != "" ? 1 : 0
  
  route_table_id         = var.public_route_table_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}

# REMOVED: Legacy fallback to avoid count dependency issues

# Route to Internet via IGW - FIXED: Only use new approach
resource "aws_route" "private_to_internet" {
  count = var.enable_internet_gateway_routes ? local.private_rt_count : 0
  
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route" "public_to_internet" {
  count = var.enable_internet_gateway_routes && local.has_public_rt ? 1 : 0
  
  route_table_id         = var.public_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# REMOVED: Legacy internet routes to avoid count dependency issues
