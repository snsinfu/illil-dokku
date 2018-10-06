resource "hcloud_ssh_key" "primary" {
  name       = "primary key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "main" {
  name        = "main"
  location    = "hel1"
  server_type = "cx11"
  image       = "debian-9"
  ssh_keys    = ["${hcloud_ssh_key.primary.id}"]
}

resource "cloudflare_record" "main" {
  domain = "${var.site_domain}"
  name   = "dokku"
  type   = "A"
  value  = "${hcloud_server.main.ipv4_address}"
}

resource "cloudflare_record" "subdomains" {
  domain = "${var.site_domain}"
  name   = "*.dokku"
  type   = "CNAME"
  value  = "dokku.${var.site_domain}"
}

data "template_file" "hosts" {
  template = "${file("hosts.ini.tpl")}"

  vars {
    server_address  = "${hcloud_server.main.ipv4_address}"
    dokku_host      = "dokku.${var.site_domain}"
    mackerel_apikey = "${var.mackerel_apikey}"
  }
}

output "ip" {
  value = "${hcloud_server.main.ipv4_address}"
}

output "inventory" {
  value = "${data.template_file.hosts.rendered}"
}
