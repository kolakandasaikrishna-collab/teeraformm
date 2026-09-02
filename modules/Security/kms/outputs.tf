output "keyring_ids" {
  description = "Map of created KMS Key Ring IDs."
  value       = { for k, kr in google_kms_key_ring.keyrings : k => kr.id }
}

output "crypto_key_ids" {
  description = "Map of created KMS Crypto Key IDs."
  value       = { for k, ck in google_kms_crypto_key.keys : k => ck.id }
}

output "cloud_armor_policy_ids" {
  description = "Map of Cloud Armor Security Policy IDs."
  value       = { for k, p in google_compute_security_policy.policies : k => p.id }
}
