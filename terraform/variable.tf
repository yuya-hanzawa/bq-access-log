variable "PROJECT" {
  default = "bigquery-access-log"
  type    = string
}

variable "REGION" {
  default = "us-central1"
  type    = string
}

variable "BUCKET" {
  default = "GCF_Access_Log_Bucket"
  type    = string
}
