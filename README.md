# terraform-oci-compartment
Terraform Module - OCI Compartment

This Terraform module allows an Oracle Cloud Infrastructure compartment to be used in either read-only mode or read/write mode. You can switch between the two modes by setting the **manage** argument to either true (a new resource will be created) or false (a data source filtered to the provided compartment name will be created).

This argument control also enable_delete value.

# Example: Basic usage
```hcl
module "my-compartment" {
  source = "Terraform-Modules-Lib/compartment/oci"
  
  # Pinning a specific version
  version = "~> 1"
  
  # Requiring a oci provider pointing to home region
  providers = {
    oci = oci.home
  }
  
  # Set your comparment name ...
  name = "my-compartment"
  # ... and its parent (can be tenancy ocid)
  parent_ocid = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  manage = true
}

output "compartment_name" {
  value = module.my-compartment.oci-compartment.name
}
```

# Example: Multiple compartments
```hcl
module "compartment-envs" {
  for_each = toset(["dev,", "test", "QA", "prod"])
  source = "Terraform-Modules-Lib/compartment/oci"
  version = "~> 0"
  
  providers = {
    oci = oci.home
  }

  name = each.value
  parent_ocid = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

output "compartment-envs" {
  value = { for env, compartment in module.compartment-envs:
    env => compartment.oci-compartment.id
  }
}
```

