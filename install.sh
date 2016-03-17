#!/bin/bash
echo "installing gems"
bundle install
echo "creating symlink into /usr/local/bin (you can cancel this) - might need root"
ln -fs `pwd`/docker_registry.rb /usr/local/bin/docker_registry || sudo ln -fs `pwd`/registry.rb /usr/local/bin/docker_registry