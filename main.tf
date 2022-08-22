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
  this = try(
    oci_identity_compartment.this[0],
    data.oci_identity_compartments.this.compartments[0],
    ""
  )

  parent = data.oci_identity_compartment.parent

  defined_tags = var.inheritance_tags && var.inheritance_defined_tags ? merge(local.parent.defined_tags, var.defined_tags) : var.defined_tags
  freeform_tags = var.inheritance_tags && var.inheritance_freeform_tags ? merge(local.parent.freeform_tags, var.freeform_tags) : var.freeform_tags
}

data "oci_identity_compartment" "parent" {
  id = var.parent_ocid
}

data "oci_identity_compartments" "this" {
  compartment_id = local.parent.id
  name = var.name

  access_level = "ANY"
  compartment_id_in_subtree = false
}

resource "oci_identity_compartment" "this" {
  count = var.manage ? 1 : 0

  compartment_id = local.parent.id
  description = coalesce(var.description, var.name)
  name = var.name

  defined_tags = local.defined_tags
  freeform_tags = local.freeform_tags

  enable_delete = var.manage
}

resource "oci_identity_group" "admins" {
  for_each = {
    for compartment in oci_identity_compartment.this :
        compartment.id => compartment
  }

  compartment_id = var.tenancy_ocid

  name = "${each.value.name}-admins"
  description = "Compartment ${each.value.name}'s administrators."
}
  
resource "oci_identity_policy" "compartment_admins" {
  for_each = {
    for group in oci_identity_group.admins :
        group.id => group
  }
  
  compartment_id = var.tenancy_ocid
  
  name = each.value.name
  description = "Grants for compartment ${oci_identity_compartment.this[0].name}'s adminstrators group (${each.value.name})."
    statements = [
      "Allow group ${each.value.name} to use users in tenancy",
      "Allow group ${each.value.name} to manage groups in tenancy where target.group.name = '${each.value.name}'",
      "Allow group ${each.value.name} to manage policies in compartment ${oci_identity_compartment.this[0].name}",
      "Allow group ${each.value.name} to manage all-resources in compartment ${oci_identity_compartment.this[0].name}",
    ]
}
