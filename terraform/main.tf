provider "google" {
  project     = var.project
  region      = var.region
}

# terraform plan時にzipファイルがローカルに作成される
data "archive_file" "functions_archive" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/src"
  output_path = "${path.module}/../functions/zip/functions.zip"
}

# zipファイルをアップロードするためのbucket
resource "google_storage_bucket" "functions_access_log_bucket" {
  name          = "functions_access_log_bucket"
  project       = var.project
  location      = "US"
  force_destroy = true
}

# ローカルのzipファイルがGCSへアップロードする
resource "google_storage_bucket_object" "functions_zip" {
  name   = "functions.zip"
  bucket = google_storage_bucket.functions_access_log_bucket.name
  source = data.archive_file.functions_archive.output_path
}

resource "google_pubsub_topic" "access_log_topic" {
  name    = "access_log_topic"
  project = var.project
}

resource "google_cloud_scheduler_job" "access_log_scheduler" {
  name        = "access_log_scheduler"
  region      = var.region
  project     = var.project
  schedule    = "0 9 * * *"
  time_zone   = "Asia/Tokyo"

  pubsub_target {
    topic_name = "${google_pubsub_topic.access_log_topic.id}"
    data       = "${base64encode("access_log_scheduler")}"
  }
}

resource "google_cloudfunctions_function" "access_log" {
  name        = "access_log"
  project     = var.project
  region      = "us-central1"
  runtime     = "python37"
  entry_point = "main"

  source_archive_bucket = google_storage_bucket.functions_access_log_bucket.name
  source_archive_object = google_storage_bucket_object.functions_zip.name

  environment_variables = {
    PORTS        = var.ports
    USERNAME    = var.username
    PASSWORD    = var.passwd
  }

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.access_log_topic.name
  }
}
