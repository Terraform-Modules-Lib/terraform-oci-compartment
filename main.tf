terraform {
  required_version = "~> 1"

  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 4"
    }
  }
  
}

locals {
  compartment = try(
    oci_identity_compartment.compartment[0],
    data.oci_identity_compartments.compartments.compartments[0],
    ""
  )
  
  group_admins = try(
    oci_identity_group.group_admins[0],
    ""
  )
  
  policy_admins = try(
    oci_identity_policy.policy_admins[0],
    ""
  )

  parent = data.oci_identity_compartment.parent

  defined_tags = var.inheritance_tags && var.inheritance_defined_tags ? merge(local.parent.defined_tags, var.defined_tags) : var.defined_tags
  freeform_tags = var.inheritance_tags && var.inheritance_freeform_tags ? merge(local.parent.freeform_tags, var.freeform_tags) : var.freeform_tags
}

data "oci_identity_compartment" "parent" {
  id = var.parent_ocid
}

data "oci_identity_compartments" "compartments" {
  compartment_id = local.parent.id
  name = var.name

  access_level = "ANY"
  compartment_id_in_subtree = false
}

resource "oci_identity_compartment" "compartment" {
  count = var.manage ? 1 : 0

  compartment_id = local.parent.id
  description = coalesce(var.description, var.name)
  name = var.name

  defined_tags = local.defined_tags
  freeform_tags = local.freeform_tags

  enable_delete = var.manage
}

resource "oci_identity_group" "group_admins" {
  count = var.manage ? 1 : 0

  compartment_id = var.tenancy_ocid

  name = "${local.compartment.name}-admins"
  description = "Compartment ${local.compartment.name}'s administrators."
}
  
resource "oci_identity_policy" "policy_admins" {
  count = var.manage ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  
  name = local.compartment.name
  description = "Grants for compartment ${local.compartment.name}'s adminstrators group (${local.group_admins.name})."
    statements = [
      "Allow group ${local.group_admins.name} to use users in tenancy",
      "Allow group ${local.group_admins.name} to manage groups in tenancy where target.group.name = '${local.group_admins.name}'",
      "Allow group ${local.group_admins.name} to manage policies in compartment id ${local.compartment.id}",
      "Allow group ${local.group_admins.name} to manage all-resources in compartment id ${local.compartment.id}",
    ]
}
