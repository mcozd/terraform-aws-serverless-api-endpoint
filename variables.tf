variable "http_method" {
  type    = string
  default = "GET"
  validation {
    condition     = contains(["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"], var.http_method)
    error_message = "Only valid HTTP VERBS are allowed (GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD)."
  }
}

variable "log_level" {
  type        = string
  description = "Sets the log level of the rest resource in api gateway. Allowed values are OFF, ERROR, INFO."
  default     = "INFO"
  validation {
    condition     = contains(["OFF", "ERROR", "INFO"], var.log_level)
    error_message = "Allowed values are {OFF, ERROR, INFO}."
  }
}

variable "authorization" {
  type = object({
    auth_type = string
    allow_for = optional(
      list(object({
        operation = string
        variable  = string
        values    = list(string)
      }))
    )
    authorizer = optional(
      object({
        id = string
      })
    )
  })

  description = "All information that is required for authorization. Currently only NONE and AWS_IAM are supported."
  default = {
    auth_type  = "NONE"
    allow_for  = null
    authorizer = null
  }
  validation {
    condition     = contains(["NONE", "AWS_IAM", "CUSTOM"], var.authorization.auth_type)
    error_message = "Only NONE, AWS_IAM and CUSTOM are currently supported."
  }
  validation {
    condition     = contains(["NONE", "CUSTOM"], var.authorization.auth_type) ? var.authorization.allow_for == null : true
    error_message = "When choosing NONE as authorization type, you cannot attach any permissions."
  }

  validation {
    condition     = var.authorization.auth_type == "CUSTOM" ? var.authorization.authorizer != null : true
    error_message = "When choosing CUSTOM as authorization type, you also have to specify the authorizer properties."
  }
}

variable "resource" {
  type = object({
    existing = optional(object({
      path = string
    }))
    new_path = optional(object({
      parent_resource_id = string
      last_path_part     = string
    }))
  })

  description = "The REST resource that you want to create or an existing resource that you want to attach the new operation."
  validation {
    condition     = (var.resource.existing == null && var.resource.new_path != null) || (var.resource.existing != null && var.resource.new_path == null)
    error_message = "You either have to reference the existing path or supply values for a new path."
  }
}

variable "function" {
  type        = any
  description = "The function that is backing your configured endpoint."
}

variable "api" {
  type        = any
  description = "The rest api that you want the endpoint to be added to."
}

variable "stage" {
  type        = any
  description = "The stage e.g. to set method settings and where endpoint configuration will be deployed."
}
