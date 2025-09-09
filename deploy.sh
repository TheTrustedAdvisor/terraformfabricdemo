#!/bin/bash

# Microsoft Fabric Terraform Deployment Script
# This script helps deploy the Fabric infrastructure

set -e

echo "🚀 Microsoft Fabric Terraform Deployment"
echo "========================================="

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "⚠️  Please edit terraform.tfvars with your desired values before continuing."
    echo "   Workspace name and other settings can be customized."
    read -p "Press Enter to continue after editing terraform.tfvars..."
fi

# Initialize Terraform if not already done
if [ ! -d ".terraform" ]; then
    echo "🔄 Initializing Terraform..."
    terraform init
fi

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Show plan
echo "📋 Showing deployment plan..."
terraform plan

# Ask for confirmation
echo ""
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying Fabric infrastructure..."
    terraform apply
    
    echo ""
    echo "🎉 Deployment completed!"
    echo ""
    echo "📊 Resource Information:"
    echo "========================"
    terraform output
    
    echo ""
    echo "🔗 Next Steps:"
    echo "1. Visit https://fabric.microsoft.com and navigate to your workspace"
    echo "2. Run the data pipeline to populate your lakehouses with sample data"
    echo "3. Explore the data using SQL endpoints or Fabric notebooks"
    echo ""
    echo "📖 For more information, see the README.md file"
else
    echo "❌ Deployment cancelled."
fi
