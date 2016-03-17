# WAT?#
This cli-tool lets you query your private docker registry for different things. For now, there is no tool provided by docker to do so 

# Installation#

     git clone https://github.com/EugenMayer/docker_registry_cli && cd docker_registry_cli && ./install.sh

For manual installation

1. get the repo and run bundle install
2. create a symlink 'docker_registry' into /usr/local/bin or were it suits you best

# Usage#
For help see


    docker_registry --help


### Examples###
List all repositories: 


    docker_registry list

> nginx
> php
> php7
> percona

List all repositories: 

    docker_registry search php

> php
> php7

    docker_registry tags nginx

> latest

# Configuration#
To ease up your usage and still be secure, do

1. If you did yet not do so, login into your registry using your local docker.
`
docker login <yourdomain>
`
This creates a ~/.docker/config.json with your credentials encrypted and also lets you push on your registry now.


2. 
`
echo "domain: <yourdomain>\n" > ~/.docker_registry.yml
`
This defines the default domain to query for

Alternatively (not recommended):
Enter your user: and password: into the configuration file listed above

# Limitations#

- Basic Auth only
- HTTPS only (i consider HTTP to be a bug)
- API v2 only

# Contribute#
You want better or new commands like deleting images, containers, layers .. well, why dont you do so and create a pull-request :)