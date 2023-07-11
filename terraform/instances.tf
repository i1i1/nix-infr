resource "vultr_dns_domain" "domain" {
  domain = "thatsverys.us"
}

resource "vultr_instance" "mail" {
  label       = "mail"
  plan        = var.one_cpu_one_gb_ram
  region      = var.europe
  snapshot_id = var.nixos_snapshot_id_25gb
}

# Used this guide to setup dns records: https://nixos-mailserver.readthedocs.io/en/latest/setup-guide.html
resource "vultr_dns_record" "a_mail" {
  domain = vultr_dns_domain.domain.id
  name   = "mail"
  data   = vultr_instance.mail.main_ip
  type   = "A"
}

resource "vultr_reverse_ipv4" "mail_reverse_ipv4" {
  instance_id = vultr_instance.mail.id
  ip          = vultr_instance.mail.main_ip
  reverse     = "${vultr_dns_record.a_mail.name}.${vultr_dns_domain.domain.domain}"
}

resource "vultr_dns_record" "mx_mail" {
  domain   = vultr_dns_domain.domain.id
  name     = ""
  data     = vultr_reverse_ipv4.mail_reverse_ipv4.reverse
  priority = 10
  type     = "MX"
}

resource "vultr_dns_record" "spf_mail" {
  domain = vultr_dns_domain.domain.id
  name   = ""
  data   = "v=spf1 a:${vultr_dns_record.mx_mail.data} -all"
  type   = "TXT"
}

resource "vultr_dns_record" "dkim_mail" {
  domain = vultr_dns_domain.domain.id
  name   = "${vultr_dns_record.a_mail.name}._domainkey"
  data   = "v=DKIM1; p=${var.dkim_mail_pubkey}"
  type   = "TXT"
}

resource "vultr_dns_record" "dmarc_mail" {
  domain = vultr_dns_domain.domain.id
  name   = "_dmarc"
  data   = "v=DMARC1; p=none"
  type   = "TXT"
}
