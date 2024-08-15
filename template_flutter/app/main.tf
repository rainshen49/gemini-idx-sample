terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0.0"
    }
  }
}

provider "google" {
  user_project_override = true
}

variable "project" {
  type = string
}

data "google_project" "project" {
  project_id = var.project
}

resource "google_project_service" "services" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "generativelanguage.googleapis.com",
    "apikeys.googleapis.com",
    "firestore.googleapis.com",
    "firebaserules.googleapis.com",
  ])
  project = var.project
  service = each.value

  disable_on_destroy = false
}

# Protect the project with a low initial quota
resource "google_service_usage_consumer_quota_override" "generativelanguage" {
  project        = var.project
  service        = "generativelanguage.googleapis.com"
  metric         = urlencode("generativelanguage.googleapis.com/generate_requests_per_model")
  limit          = urlencode("/min/model/project")
  override_value = "10"
  force          = true

  depends_on = [google_project_service.services]
}

resource "google_apikeys_key" "generativelanguage" {
  project = var.project

  name         = "gemini-api-key"
  display_name = "Gemini API Key"

  restrictions {
    api_targets {
      service = "generativelanguage.googleapis.com"
    }

    browser_key_restrictions {
      allowed_referrers = ["*"]
    }
  }

  depends_on = [google_project_service.services]
}

resource "google_firestore_database" "database" {
  project     = var.project
  name        = "(default)"
  location_id = "nam5"
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.services]
}

resource "google_firebaserules_ruleset" "firestore" {
  project = var.project

  source {
    files {
      content = file("firestore.rules")
      name    = "firestore.rules"
    }
  }

  depends_on = [google_firestore_database.database]
}

resource "google_firebaserules_release" "firestore" {
  project = var.project

  name         = "cloud.firestore"
  ruleset_name = google_firebaserules_ruleset.firestore.name
}

resource "google_firebase_web_app" "example" {
  project = var.project

  display_name    = "Flutter Web App"
  api_key_id      = google_apikeys_key.generativelanguage.uid
  deletion_policy = "DELETE"
}

resource "google_firebase_android_app" "example" {
  project = var.project

  display_name = "Flutter Android App"
  package_name = "com.example.app"
  api_key_id   = google_apikeys_key.generativelanguage.uid

  deletion_policy = "DELETE"
}

data "google_firebase_android_app_config" "example" {
  project = var.project
  app_id  = google_firebase_android_app.example.app_id
}

data "google_firebase_web_app_config" "example" {
  project    = var.project
  web_app_id = google_firebase_web_app.example.app_id
}

resource "local_file" "api_key" {
  content = jsonencode({
    GEN_AI_API_KEY = google_apikeys_key.generativelanguage.key_string
  })
  filename = "${path.module}/env.json"
}

resource "local_file" "google_services_json" {
  content_base64 = data.google_firebase_android_app_config.example.config_file_contents
  filename       = "${path.module}/android/app/${data.google_firebase_android_app_config.example.config_filename}"
}

resource "local_file" "firebase_options_dart" {
  content = templatefile("${path.module}/lib/firebase_options.dart.tftpl", {
    project_id          = var.project,
    messaging_sender_id = data.google_project.project.number,

    web_app_id      = google_firebase_web_app.example.app_id,
    web_app_api_key = data.google_firebase_web_app_config.example.api_key,

    android_app_id      = google_firebase_android_app.example.app_id,
    android_app_api_key = jsondecode(base64decode(data.google_firebase_android_app_config.example.config_file_contents))["client"][0]["api_key"][0]["current_key"],
  })
  filename = "${path.module}/lib/firebase_options.dart"
}

resource "local_file" "firebaserc" {
  content = jsonencode({
    projects = {
      default = var.project
    }
  })
  filename = "${path.module}/.firebaserc"
}

resource "local_file" "firebase_json" {
  content = jsonencode({
    flutter = {
      platforms = {
        android = {
          default = {
            projectId  = var.project,
            appId      = google_firebase_android_app.example.app_id,
            fileOutput = "android/app/${data.google_firebase_android_app_config.example.config_filename}"
          }
        },
        dart = {
          "lib/firebase_options.dart" = {
            projectId = var.project,
            configurations = {
              android = google_firebase_android_app.example.app_id,
              web     = google_firebase_web_app.example.app_id
            }
          }
        }
      }
    }
  })
  filename = "${path.module}/firebase.json"
}
