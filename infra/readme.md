La infraestructura se gestiona mediante Terraform utilizando una estructura modular que permite reutilización, separación de entornos y escalabilidad a múltiples clusters o regiones sin duplicar código.

main.tf             = Logic
variables.tf        = Contrato
terraform.tfvars    = data
versions.tf         = Rules