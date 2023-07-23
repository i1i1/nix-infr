resource "vultr_dns_domain" "domain" {
  domain = "thatsverys.us"
}

resource "vultr_instance" "server" {
  label       = "server"
  plan        = var.two_cpu_four_gb_ram
  region      = var.europe
  snapshot_id = var.nixos_snapshot_id_100gb_ssd
  backups     = "enabled"
  backups_schedule {
    type = "monthly"
  }
}

resource "vultr_dns_record" "a_nextcloud" {
  domain = vultr_dns_domain.domain.id
  name   = "nc"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "a_searx" {
  domain = vultr_dns_domain.domain.id
  name   = "sx"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "a_invidious" {
  domain = vultr_dns_domain.domain.id
  name   = "in"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "a_libreddit" {
  domain = vultr_dns_domain.domain.id
  name   = "lr"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "a_vaultwarden" {
  domain = vultr_dns_domain.domain.id
  name   = "vault"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

# resource "vultr_instance" "mail" {
#   label       = "mail"
#   plan        = var.one_cpu_one_gb_ram_25gb_ssd
#   region      = var.europe
#   snapshot_id = var.nixos_snapshot_id_25gb
# }

# # Used this guide to setup dns records: https://nixos-mailserver.readthedocs.io/en/latest/setup-guide.html
# resource "vultr_dns_record" "a_mail" {
#   domain = vultr_dns_domain.domain.id
#   name   = "mail"
#   data   = vultr_instance.mail.main_ip
#   type   = "A"
# }

# resource "vultr_reverse_ipv4" "mail_reverse_ipv4" {
#   instance_id = vultr_instance.mail.id
#   ip          = vultr_instance.mail.main_ip
#   reverse     = "${vultr_dns_record.a_mail.name}.${vultr_dns_domain.domain.domain}"
# }

# resource "vultr_dns_record" "mx_mail" {
#   domain   = vultr_dns_domain.domain.id
#   name     = ""
#   data     = vultr_reverse_ipv4.mail_reverse_ipv4.reverse
#   priority = 10
#   type     = "MX"
# }

# resource "vultr_dns_record" "spf_mail" {
#   domain = vultr_dns_domain.domain.id
#   name   = ""
#   data   = "v=spf1 a:${vultr_dns_record.mx_mail.data} -all"
#   type   = "TXT"
# }

# resource "vultr_dns_record" "dkim_mail" {
#   domain = vultr_dns_domain.domain.id
#   name   = "${vultr_dns_record.a_mail.name}._domainkey"
#   data   = "v=DKIM1; p=${var.dkim_mail_pubkey}"
#   type   = "TXT"
# }

# resource "vultr_dns_record" "dmarc_mail" {
#   domain = vultr_dns_domain.domain.id
#   name   = "_dmarc"
#   data   = "v=DMARC1; p=none"
#   type   = "TXT"
# }
