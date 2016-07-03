# WAT?#
This cli-tool lets you query your private docker registry for different things. For now, there is no tool provided by docker to do so 

# Features #

1. Supporting basic auth and also token auth (Bearer token) which are used by projects like Docker-Auth or Portus
2. Reading credentials from config.json to reuse from docker login
3. list images / tags or delete those

# Installation#

    git clone https://github.com/EugenMayer/docker_registry_cli && cd docker_registry_cli && ./install.sh

or

    gem install docker_registry_cli


For manual installation

1. get the repo and run bundle install
2. create a symlink 'docker_registry' into /usr/local/bin or were it suits you best

# Usage#

For help see

    docker_registry_cli --help


### Examples###
List all repositories: 


    docker_registry_cli list

> nginx
> php
> php7
> percona

List all repositories: 

    docker_registry_cli search php

> php
> php7

    docker_registry_cli tags nginx

> latest

# Configuration#
To ease up your usage, you can add some configuration

1. If you did yet not do so (you will have..), login into your registry using your local docker.
`
docker login <yourdomain>
`
This creates a `~/.docker/config.json` with your credentials in that file (just base64 decoded, NOT encrypted). This also lets you push/pull from/to your registry from now on.

**Be aware, unless you use a credentials helper, you user/password is saved plain-text this way**

I plan to support the new docker credential helpers though

2. (skip this if you used install.sh)
`
echo "domain: <yourdomain>\n" > ~/.docker_registry.yml
`
This defines the default domain to query for

Alternatively (not recommended):
Enter your user: and password: into the configuration file listed above

3. Deleting images

If you want to delete images, be sure to enable storage->delete->true in your registry config.yml, see https://github.com/docker/distribution/blob/master/docs/configuration.md

# Limitations#
- **not supporting credential helpers yet for basic-auth**
- HTTPS only (i consider HTTP to be a bug)
- API v2 only

# Contribute#
You want better or new commands like deleting images, containers, layers .. well, why dont you do so and create a pull-request :)