variable "project_id" {
  type    = string
  default = "pro-462803f3-6858-466f-bf05-df2b33faa360"
}
variable "s_general_4x8" {
  type    = string
  default = "flav-70a62913-b591-40d0-8774-7d79d2fdfd37"
}
variable "s_general_4x8_minion" {
  type    = string
  default = "flav-f5e0201d-606f-4480-be72-de11f46d48ff"
}

variable "image_id" {
  type    = string
  default = "img-1c29f7df-fa23-4dd2-bcfb-9de14dee72e7"
}
variable "volume_type_name" {
  type    = string
  default = "3000"
}
variable "root_disk_size" {
  type    = number
  default = 20
}
variable "data_disk_size" {
  type    = number
  default = 20
}
variable "network_id" {
  type    = string
  default = "net-38cd0118-fd63-4d52-b8f3-396b3f93c56d"
}
variable "subnet_id" {
  type    = string
  default = "sub-fbc7d68b-5b1b-4c55-9399-77622e60fe49"
}
variable "ssh_key_id" {
  type    = string
  default = "ssh-eb3f73d7-5607-4a8d-8298-8d4ca9df4765"
}
variable "security_group_id_list" {
  type    = list(string)
  default = [
    "secg-5ddff4f9-b4ce-4633-8a2b-4bba28f7bb01"
  ]
}