# KMS Key Rings
resource "google_kms_key_ring" "keyrings" {
  for_each = var.keyrings
  project  = var.project_id
  name     = each.key
  location = var.location
}

# Flatten Crypto Keys
locals {
  crypto_keys = flatten([
    for keyring_name, keyring in var.keyrings : [
      for key_name, key in keyring.keys : {
        keyring_name                = keyring_name
        key_name                    = key_name
        purpose                     = key.purpose
        rotation_period             = key.rotation_period
        encrypter_decrypter_members = key.encrypter_decrypter_members
        composite_key               = "${keyring_name}/${key_name}"
      }
    ]
  ])

  key_iam_members = flatten([
    for k in local.crypto_keys : [
      for member in k.encrypter_decrypter_members : {
        keyring_name  = k.keyring_name
        key_name      = k.key_name
        member        = member
        composite_key = "${k.keyring_name}/${k.key_name}/${member}"
      }
    ]
  ])
}

resource "google_kms_crypto_key" "keys" {
  for_each        = { for k in local.crypto_keys : k.composite_key => k }
  name            = each.value.key_name
  key_ring        = google_kms_key_ring.keyrings[each.value.keyring_name].id
  purpose         = each.value.purpose
  rotation_period = each.value.rotation_period

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "encrypter_decrypters" {
  for_each      = { for m in local.key_iam_members : m.composite_key => m }
  crypto_key_id = google_kms_crypto_key.keys["${each.value.keyring_name}/${each.value.key_name}"].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = each.value.member
}

# Cloud Armor Security Policies
resource "google_compute_security_policy" "policies" {
  for_each    = var.cloud_armor_policies
  project     = var.project_id
  name        = each.key
  description = each.value.description

  dynamic "rule" {
    for_each = each.value.rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description

      match {
        versioned_expr = rule.value.match.versioned_expr
        dynamic "config" {
          for_each = rule.value.match.config != null ? [rule.value.match.config] : []
          content {
            src_ip_ranges = config.value.src_ip_ranges
          }
        }
        dynamic "expr" {
          for_each = rule.value.match.expr != null ? [rule.value.match.expr] : []
          content {
            expression = expr.value.expression
          }
        }
      }

      dynamic "rate_limit_options" {
        for_each = rule.value.rate_limit_options != null ? [rule.value.rate_limit_options] : []
        content {
          conform_action = rate_limit_options.value.conform_action
          exceed_action  = rate_limit_options.value.exceed_action
          enforce_on_key = rate_limit_options.value.enforce_on_key
          rate_limit_threshold {
            count        = rate_limit_options.value.rate_limit_threshold.count
            interval_sec = rate_limit_options.value.rate_limit_threshold.interval_sec
          }
        }
      }
    }
  }
}
