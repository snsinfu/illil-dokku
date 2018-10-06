ARTIFACTS = \
  _init.ok \
  _server.ok \
  _domain.ok \
  _provision.ok \
  terraform.tfstate \
  terraform.tfstate.backup \
  provision.retry \
  hosts.ini \
  known_hosts

SSH_OPTIONS = \
  -o UserKnownHostsFile=known_hosts \
  -o IdentitiesOnly=yes \
  -o PasswordAuthentication=no


.PHONY: all clean ssh

all: _domain.ok _provision.ok
	@:

clean:
	terraform destroy
	rm -rf $(ARTIFACTS)

ssh: _server.ok
	ssh $(SSH_OPTIONS) root@$$(terraform output ip)

_init.ok: main.tf
	terraform init
	@touch $@

_server.ok: _init.ok main.tf vars.tf
	terraform apply -target hcloud_server.main
	@touch $@

_domain.ok: _server.ok
	terraform apply -target cloudflare_record.main
	terraform apply -target cloudflare_record.subdomains
	@touch $@

hosts.ini: _server.ok main.tf vars.tf hosts.ini.tpl
	terraform apply -target data.template_file.hosts
	terraform output inventory > $@

_provision.ok: _server.ok ansible.cfg hosts.ini provision.yml
	ansible-playbook $(ANSIBLE_OPTIONS) provision.yml
	@touch $@

_provision.ok: \
  roles/*/files/* \
  roles/*/tasks/main.yml \
  roles/*/handlers/main.yml \
  certs/* \
  config/*
