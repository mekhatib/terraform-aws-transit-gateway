# Terraform AWS transit-gateway Module

This Terraform module manages AWS transit-gateway resources.

## Usage

```hcl
module "transit_gateway" {
  source  = "app.terraform.io/YOUR-ORG/transit-gateway/aws"
  version = "1.0.0"
  
  # Required variables
  environment  = "dev"
  project_name = "my-project"
  
  # Module-specific variables
  # Add based on variables.tf
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## Inputs

See [variables.tf](./variables.tf)

## Outputs

See [outputs.tf](./outputs.tf)
