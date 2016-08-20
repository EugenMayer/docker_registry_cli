#!/bin/bash
gem build docker_registry_cli.gemspec
version=`cat VERSION`
echo| gem uninstall -a --force -q docker-sync
gem install docker_registry_cli-$version.gem
rm docker_registry_cli-$version.gem
