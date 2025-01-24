# Public Infra

This is a repo containing all the code needed to deploy public service infrastructure.

Currently, the supported services are:

* Tor OBFS4 Bridges
* Tor Webtunnel Bridges

This repo should be usable for anyone to deploy this public infrastructure with minimal effort.

## Deploying
These services are deployed manually using terraform and the wonderfully declarative [Flatcar Container Linux](https://www.flatcar.org/).

Required technologies and make-style tasks are provided by [mise](https://mise.jdx.dev/).
The [1Password cli](https://developer.1password.com/docs/cli/get-started/) needs to be separately installed because I don't trust the source of the mise/asdf plugin.

```sh
# Install dependencies
# install mise if not already installed
brew install mise

# install all required dependencies (lefthook, terraform)
mise install
```

### Tor Bridges

Tor OBFS4 Bridges are managed with terraform under `bridges/`.

Tor Webtunnel Bridges are managed with terraform under `webtunnels/`.

Currently, we use a single hosting provider, Vultr, to host the bridges.

The bridges are deployed with Flatcar Container Linux or Fedora CoreOS, which
are container-optimized Linux distributions meant to be declaratively
provisioned.

They both use an ignition config to provision the node, installing
tailscale and the systemd service to run a tor obfs4 bridge via docker.
This is managed with Terraform as well.

We use a 1password service account to store the secrets needed for the
deployment.

Deploy with the following command:

```sh
mise run bridges:deploy
```

If you want to deploy without 1password, you can populate the secrets directly
in the `.env` files in `bridges/` and `webtunnels/`. You'll need to make sure
not to commit them to a public git repository if you do this.

#### Logs

Logs are stored in Tigris, an s3 compatible object store. We forward service logs using
[vector](https://vector.dev/) to a Tigris bucket.

Then, there's a hacky script that loads logs from s3 into a local Loki instance.

```sh
# start loki and grafana
mise run logs:start_services

# ship logs to loki
mise run logs:ship

# stop the services
mise run logs:down
```
