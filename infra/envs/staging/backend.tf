terraform {
    backend "gcs" {
        bucket = "tfstate-devops-test-2026"
        prefix = "staging"
    }
}

// Terraform guarda el estado de la infraestructura en un archivo (terraform.tfstate). Conflicts,  Ci/Cd not working properly.
// No locking. Corruption of state file possible with concurrent operations.

// Remote Backend -> centralized, locking, secure, shared between humans and pipelines.

// En un entorno real el bucket tiene versionin, retention que esto significa que no se pueden borrar los estados viejos y se pueden recuperar.
// SOLO Ci Cd tiene acceso de escritura al bucket, los humanos solo lectura.

// Terraform is not used with local state in real environments.