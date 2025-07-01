## Terraform Files

### provider.tf

Defines required providers and required Terraform version.

### main.tf

Defines infrastructure definitions for the provider (Azure): 
- resource group
- Cosmos DB
- Event Hub
- Azure Functions
- Other resources that we want to provision

### variables.ts

Declares variables used across the configuration, those can be overriden.

### terraform.tfvars

Provides concrete values

### outputs.tf
Defines what values should be printed after 'apply' step, such as resource IDs, connection strings, etc. (Optional)

## Terraform Process

### terraform init

Initializes the Terraform working directory and downloads required providers.
Optional '-upgrade' file to upgrade provider version.

### terraform validate

Checks configuration syntax, use of correct types.

### terraform plan

Shows action plan for what will be done.
Use '-var-file' flag if you're not using the default terraform.tfvars.

### terraform apply

Applies the changes from the action plan.
Use '-var-file' flag if you're not using the default terraform.tfvars.
Optional '-auto-approve' flag to skip prompt confirmation.

### terraform destroy

Delete all infrastructure defined in your Terraform.
Optional '-auto-approve' flag to skip prompt confirmation.
Use '-var-file' flag if you're not using the default terraform.tfvars.