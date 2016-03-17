#!/bin/bash

echo  "Please enter your registry domain like docker.mycompany.com - do not add https://, you can add a port"
read domain
echo "domain: $domain" > ~/.docker_registry.yml
echo "created configuration"
echo "installing gems"
bundle install
echo "Should i create a symlink into /usr/local/bin"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo ln -fs `pwd`/docker_registry.rb /usr/local/bin/docker_registry; break;;
        No ) echo "skipped";;
    esac
done

echo "HINT: Ensure you run docker login $domain to save your credentials encrypted"
