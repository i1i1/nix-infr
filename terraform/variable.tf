variable "vultr_warsaw" {
  description = "Vultr Warsaw Region"
  default     = "waw"
}

variable "one_cpu_one_gb_ram" {
  description = "1024 MB RAM,25 GB SSD,1.00 TB BW"
  default     = "vc2-1c-1gb"
}

variable "nixos_snapshot_id_25gb" {
  description = "Snapshot ID for NixOS"
  default     = "f5fd8211-33d8-43ee-86dd-a06cb7d7746b"
}
