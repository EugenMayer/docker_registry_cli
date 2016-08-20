#!/bin/bash
gem build docker_registry_cli.gemspec
version=`cat VERSION`
gem push docker_registry_cli-$version.gem
rm docker_registry_cli-$version.gem
git tag $version
git push
git push --tags
