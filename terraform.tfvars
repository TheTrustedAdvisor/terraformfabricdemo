# Example Terraform variables file
# Copy this file to terraform.tfvars and adjust values as needed

# Name of the Fabric workspace to create
workspace_name = "mf-demo-terraform"

# Optional: Name of existing Fabric capacity to assign workspace to
# If not specified, workspace will use shared/trial capacity (if available)
capacity_name = "mffabricdemo"

# Azure region for any supporting resources
location = "West Europe"
