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
  count = var.manage ? 1 : 0

  compartment_id = var.tenancy_ocid

  name = "${local.this.name}-admins"
  description = "Compartment ${local.this.name}'s administrators."
}
  
resource "oci_identity_policy" "compartment_admins" {
  count = var.manage ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  
  name = local.this.name
  description = "Grants for compartment ${local.this.name}'s adminstrators group (${oci_identity_group.admins[0].name})."
    statements = [
      "Allow group ${oci_identity_group.admins[0].name} to use users in tenancy",
      "Allow group ${oci_identity_group.admins[0].name} to manage groups in tenancy where target.group.name = '${oci_identity_group.admins[0].name}'",
      "Allow group ${oci_identity_group.admins[0].name} to manage policies in compartment ${local.this.name}",
      "Allow group ${oci_identity_group.admins[0].name} to manage all-resources in compartment ${local.this.name}",
    ]
}
