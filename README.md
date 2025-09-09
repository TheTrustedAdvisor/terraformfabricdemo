# Microsoft Fabric Terraform Demo

This Terraform configuration creates a complete Microsoft Fabric environment with:

- **Workspace**: A Fabric workspace with system-assigned managed identity
- **Source Lakehouse**: Contains sample customer and order data
- **Target Lakehouse**: Destination for processed data
- **Data Pipeline**: Transfers and transforms data between lakehouses

## Prerequisites

1. **Azure CLI** installed and logged in:
   ```bash
   az login
   ```

2. **Terraform** installed (version >= 1.8)

3. **Microsoft Fabric Capacity**: You need access to a Fabric capacity (not trial). The workspace can be assigned to a capacity, or you can use shared capacity if available.

4. **Permissions**: Your user account needs:
   - Fabric Admin permissions or Workspace Admin role
   - Ability to create workspaces in your Fabric tenant

## Configuration

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   workspace_name = "my-fabric-demo"
   # capacity_name = "my-fabric-capacity"  # Optional
   location = "West Europe"
   ```

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## What Gets Created

### 1. Fabric Workspace
- Name: As specified in `workspace_name` variable
- System-assigned managed identity enabled
- Optional capacity assignment

### 2. Source Lakehouse (`source-lakehouse`)
- Schema-enabled lakehouse
- Contains sample tables:
  - `sample_customers`: Customer information with demographics
  - `sample_orders`: Order transaction data

### 3. Target Lakehouse (`target-lakehouse`)
- Schema-enabled lakehouse
- Receives processed data:
  - `customers`: Copied customer data
  - `orders`: Copied order data
  - `customer_summary`: Aggregated customer analysis
  - `monthly_sales_summary`: Monthly sales metrics

### 4. Data Pipeline (`lakehouse-transfer-pipeline`)
The pipeline performs these steps:
1. **Create Sample Data**: Populates source lakehouse with test data
2. **Copy Customer Data**: Transfers customer table to target
3. **Copy Orders Data**: Transfers orders table to target
4. **Create Aggregated Views**: Builds analytical summaries

## Sample Data

The pipeline creates realistic sample data including:

**Customers (10 records)**:
- Customer demographics (name, email, country)
- Registration dates from 2023
- Purchase history summary

**Orders (10 records)**:
- Technology products (laptops, monitors, etc.)
- Order dates from 2024
- Realistic pricing and quantities

**Analytical Views**:
- Customer summary with data consistency checks
- Monthly sales aggregations with key metrics

## Accessing Your Data

After deployment, you can access your data through:

1. **Fabric Portal**: Navigate to your workspace in https://fabric.microsoft.com
2. **SQL Endpoints**: Use the connection strings from Terraform outputs
3. **OneLake Paths**: Access files directly via the OneLake endpoints

## Terraform Outputs

The configuration provides several useful outputs:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output workspace_id
terraform output source_lakehouse_onelake_path
terraform output target_lakehouse_onelake_path
```

## Running the Pipeline

Once deployed, you can run the data pipeline:

1. Go to the Fabric portal
2. Navigate to your workspace
3. Find the "lakehouse-transfer-pipeline"
4. Click "Run" to execute the data transfer

The pipeline will:
- Create sample data in the source lakehouse
- Transfer data to the target lakehouse
- Generate analytical summaries

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Troubleshooting

### Authentication Issues
- Ensure you're logged in: `az login`
- Verify your account has Fabric permissions
- Check if you're in the correct Azure tenant

### Capacity Issues
- Trial capacities are not supported
- Ensure you have access to a paid Fabric capacity
- Or remove the `capacity_id` assignment to use shared capacity

### Pipeline Execution Issues
- Check that both lakehouses are created successfully
- Verify the workspace has the necessary permissions
- Review pipeline execution logs in the Fabric portal

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Source        │    │   Data Pipeline  │    │   Target        │
│   Lakehouse     │───▶│                  │───▶│   Lakehouse     │
│                 │    │   - Create Data  │    │                 │
│ - Customers     │    │   - Copy Tables  │    │ - Customers     │
│ - Orders        │    │   - Transform    │    │ - Orders        │
│                 │    │   - Aggregate    │    │ - Summaries     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Next Steps

1. **Explore the Data**: Use Fabric notebooks or SQL to query your lakehouses
2. **Extend the Pipeline**: Add more transformation steps or data sources
3. **Schedule Execution**: Set up pipeline triggers for automated runs
4. **Monitor**: Use Fabric's monitoring capabilities to track pipeline performance
