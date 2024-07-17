  variable "subscription_id" {
    type = string
  }
  variable "tenant_id" {
    type = string
  }
  variable "client_id" {
  type = string
  }
  variable "client_secret" {
  type = string
  }
  
variable "ad_groups" {
  description = "Azure AD groups to be added"
  type = list(object({
    display_name = string,
      description  = string,
    scope        = string,
    role         = string
  }))
  default = [
    {
      display_name = "Group1"
      description  = "some description",
      scope        = "/subscriptions/xxxxx/resourcegroups/myrg" #resource group scope
      role         = "Reader"      
    }
  ]
}
