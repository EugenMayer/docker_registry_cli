#!/bin/bash

echo  "Please enter your registry domain like docker.mycompany.com - do not add https://, you can add a port"
read domain
echo "domain: $domain" > ~/.docker_registry.yml
echo "created configuration"
echo "installing gems"
bundle install
echo "Should i create a symlink into /usr/local/bin (needs sudo permissions)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo ln -fs `pwd`/bin/docker_registry_cli /usr/local/bin/docker_registry_cli; break;;
        No ) echo "skipped";;
    esac
done
