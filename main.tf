# Microsoft Fabric Terraform Configuration
# This configuration creates a workspace with two lakehouses and a data pipeline
# to transfer data between them with sample data

terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Microsoft Fabric Provider
provider "fabric" {
  # Uses Azure CLI authentication by default
  # Make sure you're logged in with 'az login' before running terraform
}

# Configure the Azure Provider for capacity lookup
provider "azurerm" {
  features {}
}

# Variables
variable "workspace_name" {
  description = "Name of the Fabric workspace"
  type        = string
  default     = "mf-terraform-fabric-demo"
}

variable "capacity_name" {
  description = "Name of the Fabric capacity to use (optional)"
  type        = string
  default     = "mffabricdemo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "additional_workspace_admins" {
  description = "List of additional users to grant workspace admin access"
  type        = list(string)
  default     = ["matthias.gessenay@corporatesoftware.ch"]
}

# Data source to find existing Fabric capacity (optional)
data "fabric_capacity" "main" {
  count        = var.capacity_name != null ? 1 : 0
  display_name = var.capacity_name
}

# Create Fabric Workspace
resource "fabric_workspace" "main" {
  display_name = var.workspace_name
  description  = "Demo workspace created with Terraform for lakehouse and pipeline testing"
  
  # Optional: Assign to capacity if specified
  capacity_id = var.capacity_name != null ? data.fabric_capacity.main[0].id : null
  
  # Enable system-assigned managed identity
  identity = {
    type = "SystemAssigned"
  }
}

# Add workspace role assignments for additional admins
resource "fabric_workspace_role_assignment" "admin_assignments" {
  count = length(var.additional_workspace_admins)
  
  workspace_id = fabric_workspace.main.id
  principal = {
    id   = var.additional_workspace_admins[count.index]
    type = "User"
  }
  role = "Admin"
}

# Create Source Lakehouse
resource "fabric_lakehouse" "source" {
  display_name = "SourceLakehouse"
  description  = "Source lakehouse containing sample data"
  workspace_id = fabric_workspace.main.id
  
  configuration = {
    enable_schemas = true
  }
}

# Create Target Lakehouse
resource "fabric_lakehouse" "target" {
  display_name = "TargetLakehouse"
  description  = "Target lakehouse for data pipeline transfers"
  workspace_id = fabric_workspace.main.id
  
  configuration = {
    enable_schemas = true
  }
}

# Create Data Pipeline to transfer data between lakehouses
resource "fabric_data_pipeline" "transfer_pipeline" {
  display_name = "LakehouseTransferPipeline"
  description  = "Pipeline to transfer data from source to target lakehouse"
  workspace_id = fabric_workspace.main.id
  format       = "Default"
  
  definition = {
    "pipeline-content.json" = {
      source = "pipeline-content.json"
      tokens = {
        "SourceLakehouseId"   = fabric_lakehouse.source.id
        "TargetLakehouseId"   = fabric_lakehouse.target.id
        "SourceLakehouseName" = fabric_lakehouse.source.display_name
        "TargetLakehouseName" = fabric_lakehouse.target.display_name
        "WorkspaceId"         = fabric_workspace.main.id
      }
    }
  }
  
  depends_on = [
    fabric_lakehouse.source,
    fabric_lakehouse.target
  ]
}

# Outputs
output "workspace_id" {
  description = "ID of the created Fabric workspace"
  value       = fabric_workspace.main.id
}

output "workspace_name" {
  description = "Name of the created Fabric workspace"
  value       = fabric_workspace.main.display_name
}

output "source_lakehouse_id" {
  description = "ID of the source lakehouse"
  value       = fabric_lakehouse.source.id
}

output "source_lakehouse_onelake_path" {
  description = "OneLake path to source lakehouse files"
  value       = fabric_lakehouse.source.properties.onelake_files_path
}

output "target_lakehouse_id" {
  description = "ID of the target lakehouse"
  value       = fabric_lakehouse.target.id
}

output "target_lakehouse_onelake_path" {
  description = "OneLake path to target lakehouse files"
  value       = fabric_lakehouse.target.properties.onelake_files_path
}

output "data_pipeline_id" {
  description = "ID of the data transfer pipeline"
  value       = fabric_data_pipeline.transfer_pipeline.id
}

output "source_lakehouse_sql_endpoint" {
  description = "SQL endpoint connection string for source lakehouse"
  value       = fabric_lakehouse.source.properties.sql_endpoint_properties.connection_string
  sensitive   = true
}

output "target_lakehouse_sql_endpoint" {
  description = "SQL endpoint connection string for target lakehouse"
  value       = fabric_lakehouse.target.properties.sql_endpoint_properties.connection_string
  sensitive   = true
}
