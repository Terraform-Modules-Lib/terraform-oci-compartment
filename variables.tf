variable "tenancy_ocid" {
    type = string
    description = "(Required) (Updatable) The OCID of the tenancy (root compartment) containing the compartment."

    validation {
      condition = contains(["ocid1.tenancy.oc1"],
        split("..", var.tenancy_ocid)[0]
      )
      error_message = "The tenancy_ocid value must be a valid tenancy OCID."
    }
}

variable "parent_ocid" {
    type = string
    description = "(Required) (Updatable) The OCID of the parent compartment containing the compartment."

    validation {
      condition = contains(["ocid1.compartment.oc1", "ocid1.tenancy.oc1"],
        split("..", var.parent_ocid)[0]
      )
      error_message = "The parent_ocid value must be a valid compartment or tenancy OCID."
    }
}

variable "name" {
    type = string
    description = "(Required) (Updatable) The name you assign to the compartment during creation. The name must be unique across all compartments in the parent compartment. Avoid entering confidential information."
}

variable "description" {
    type = string
    description = "(Optional) (Updatable) The description you assign to the compartment during creation. Does not have to be unique, and it's changeable."
    default = ""
}

variable "defined_tags" {
  type = map(string)
  description = "(Optional) (Updatable) Defined tags for this resource. Each key is predefined and scoped to a namespace."
  default = {}
}

variable "freeform_tags" {
  type = map(string)
  description = "(Optional) (Updatable) Free-form tags for this resource. Each tag is a simple key-value pair with no predefined name, type, or namespace."
  default = {}
}

variable "inheritance_tags" {
  type = bool
  description = "(Optional) (Updatable) Inheritance defined_tags and freeform_tags from parent compartments."
  default = true
}

variable "inheritance_defined_tags" {
  type = bool
  description = "(Optional) (Updatable) Inheritance only defined_tags from parent compartments."
  default = true
}

variable "inheritance_freeform_tags" {
  type = bool
  description = "(Optional) (Updatable) Inheritance only freeform_tags from parent compartments."
  default = true
}

variable "manage" {
  type = bool
  description = "(Optional) (Updatable) If true, the compartment will be managed by this module. If false, compartment data will be returned about the compartment if it exists. if not found, then an empty string will be returned for the compartment ID."
  default = true
}
