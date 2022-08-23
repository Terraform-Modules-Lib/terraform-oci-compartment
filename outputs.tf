output "oci_compartment" {
    value = local.compartment
    description = "Return an oci_identity_compartment resource or an empty string."
}

output "oci_group_admins" {
    value = local.group_admins
    description = "Return an oci_identity_group resource or an empty string."
}

output "oci_policy_admin" {
    value = local.policy_admin
    description = "Return an oci_identity_policy resource or an empty string."
}
