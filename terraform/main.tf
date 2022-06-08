provider "google" {
  project = var.PROJECT
  region  = var.REGION
}

module "gcp_services" {
  source = "./modules/"
  BUCKET = var.BUCKET
  REGION = var.REGION
}
