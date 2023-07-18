variable "europe" {
  description = "Vultr Warsaw Region"
  default     = "waw"
}

variable "one_cpu_one_gb_ram_25gb_ssd" {
  description = "1024 MB RAM,25 GB SSD,1.00 TB BW"
  default     = "vc2-1c-1gb"
}

variable "nixos_snapshot_id_25gb" {
  description = "Snapshot ID for NixOS for disk size of 100gb"
  default     = "2991f8b2-3547-498e-abfb-aa28aa9ae50a"
}

variable "two_cpu_four_gb_ram" {
  description = "2048 MB RAM,100 GB SSD,5.00 TB BW"
  default     = "vhp-2c-4gb-amd"
}

variable "nixos_snapshot_id_100gb_ssd" {
  description = "Snapshot ID for NixOS for disk size of 100gb"
  default     = "be7ff799-6e90-4749-96a5-b958fb85f03f"
}

variable "dkim_mail_pubkey" {
  description = <<EOT
  Public key for mail. Get it with the following command:
   ssh nixos@{vultr_dns_record.mx_mail.data} \
     cat /var/dkim/{vultr_dns_domain.domain.domain}.{vultr_dns_record.a_mail.name}.txt |
       grep p= |
       cut -d'"' -f2 |
       cut -d= -f2
  EOT
  default     = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDKV3lZkHUhMEJ4cqDHQoYh9S9eCKDo2hpE3ssQYVTX6nhl63JxQgOSAswt+n3SwjqGDUBANqwbBIs5Z6QwnRL+CiEK5fAsO/MgnAVqkBfCZ0CmhTawmhsPClBl90f3JyHFtNAWyNyAv3mGun7Nr0JNcubXgpg9Ht8S5MNFbS4QQwIDAQAB"
}
