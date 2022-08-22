output "oci-compartment" {
    value = local.this
    description = "Return an oci_identity_compartment resource or an empty string."
}

output "oci-group-admins" {
    value = local.group_admins
    description = "Return an oci_identity_group resource or an empty string."
}

output "oci-policy-admins" {
    value = local.policy_admins
    description = "Return an oci_identity_policy resource or an empty string."
}
