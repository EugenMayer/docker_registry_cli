[![Gem Version](https://badge.fury.io/rb/docker_registry_cli.svg)](https://badge.fury.io/rb/docker_registry_cli)

# WAT?#
This cli-tool lets you query your private docker registry for different things and delete them 

# Features #

1. List/Delete images and/or tags
1. Supports _Basic Auth_ and _Bearer Token Auth_ which are used by projects like Docker-Auth or Portus
1. Supports credential helper (preferred) and config.json auth (plain text auth, so will be removed in the future) 

# Installation#

    gem install docker_registry_cli

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

Delete a tag

    docker_registry_cli delete_tag someimage sometag

Delete a image

    docker_registry_cli delete_image someimage

# Configuration#
To ease up your usage, you can add some configuration

1. If you did yet not do so (you will have..), login into your registry using your local docker.
`
docker login <yourdomain>
`
This creates a `~/.docker/config.json`. From docker 1.11 it will be automatically using the [credential helper](http://www.projectatomic.io/blog/2016/03/docker-credentials-store/): 

**In any way you should always use the credential helper, see [here](https://docs.docker.com/engine/reference/commandline/login/)**

Be aware, unless you use a credentials helper, your user/password is saved **plain-text!**

Alternatively (not recommended):
Provide user and password on each cli call

2. optionally, define a default domain
`
echo "domain: <yourdomain>\n" > ~/.docker_registry.yml
`
This defines the default domain to query for


# Advanced
Deleting images

If you want to delete images, be sure to enable storage->delete->true in your registry-installation config.yml, see https://github.com/docker/distribution/blob/master/docs/configuration.md

# Limitations#
- HTTPS only (i consider HTTP to be a bug)

# Contribute#
Happy to merge in pull requests!