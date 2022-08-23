# terraform-oci-compartment
Terraform Module - OCI Compartment

This Terraform module allows an Oracle Cloud Infrastructure compartment to be used in either read-only mode or read/write mode. You can switch between the two modes by setting the **manage** argument to either true (a new resource will be created) or false (a data source filtered to the provided compartment name will be created).

This argument control also enable_delete value.

# Example: Basic usage
```hcl
module "my-compartment" {
  source = "Terraform-Modules-Lib/compartment/oci"
  
  # Pinning a specific version
  version = "~> 4"
  
  # Requiring a oci provider pointing to home region
  providers = {
    oci = oci.home
  }
  
  # Set your comparment name ...
  name = "my_compartment"
  # ... and its parent (can be tenancy ocid)
  parent_ocid = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  
  # Provide tenancy ocid to create admin group and related policy
  tenanct_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  manage = true
}

output "compartment_name" {
  value = module.my_compartment.oci_compartment.name
}

output "admins_name" {
  value = module.my_compartment.oci_group_admins.name
}

output "policy_name" {
  value = module.my_compartment.oci_policy_admins.name
}
```

# Example: Multiple compartments
```hcl
module "compartment-envs" {
  for_each = toset(["env1", "env2", "env3"])
  source = "Terraform-Modules-Lib/compartment/oci"
  version = "~> 0"
  
  providers = {
    oci = oci.home
  }

  name = each.value
  parent_ocid = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenanct_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

locals {
  # Create an array of oci_identity_compartment
  compartments = [ for compartment in module.compartment-envs:
    compartment.oci_compartment
  ]
  
  # Create an array of oci_identity_group
  groups_admins = [ for compartment in module.compartment-envs:
    compartment.oci_group_admins
  ]
  
  # Create an array of oci_identity_policy 
  policies_admin = [ for compartment in module.compartment-envs:
    compartment.policy_admin
  ]
}

output "compartment_envs" {
  value = { for compartment in local.compartments:
    compartment.name => compartment.id
  }
}

output "group_admins_envs" {
  value = { for group in local.groups_admins:
    group.name => group.id
  }
}

output "policies_admin_envs" {
  value = { for policy in local.policies_admin:
    policy.name => policy.id
  }
}
```
