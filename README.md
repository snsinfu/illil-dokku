# Dokku behind Cloudflare

Set environment variables:

```
HCLOUD_TOKEN=...
CLOUDFLARE_EMAIL=...
CLOUDFLARE_TOKEN=...
TF_VAR_mackerel_apikey=...
TF_VAR_site_domain=example.com
```

Put Cloudflare origin cert in `certs` directory:

```
certs/
  origin.cert
  origin.key
```

Run `make` to deploy a server. You can easilly ssh into the server with
`make ssh`--though it is not necessary as a dokku client can manage the
platform. `make clean` destroys the server and cleans up artifacts.
