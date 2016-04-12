#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'httparty'
require 'yaml'
require 'pp'

class DockerRegistryRequest
  include HTTParty
  format :json
  headers 'Content-Type' => 'application/json'
  headers 'Accept' => 'application/json'
  @@debug = false

  def initialize(domain, user = nil, pass = nil, debug = false)
    @@debug = debug
    self.class.base_uri "https://#{domain}/v2"
    handle_auth(domain, user, pass)
  end

  def handle_auth(domain, user = nil, pass = nil)
    if user && pass
      # this will base64 encode automatically
      self.class.basic_auth user, pass
    else
      begin
        # load the docker config and see, if the domain is included there - reuse the auth token
        config = JSON.parse(File.read(File.join(ENV['HOME'], '.docker/config.json')))
        token = config['auths'][domain]['auth']
        if(!token)
          pp config if @@debug
          throw('No auth token found for this domain')
        end

        pp "Using existing token from config.json #{token}" if @@debug
        # set the Authorization header directly, since it is already base64 encoded
        self.class.headers['Authorization'] = "Basic #{token}"
      rescue Exception
        puts "No --user or --password. Still you did not yet login with 'docker login #{domain}'. Either set user and passwortd or login using 'docker login #{domain}'".colorize(:red)
        puts Exception.to_s if @@debug
      end
    end
    login_test
  end

  ### check if the login actually will succeed
  def login_test
    result = self.class.get("/").parsed_response
    if result.has_key?("errors")
      puts "Wrong credentials or wrong URI".colorize(:red)
      pp result
      exit
    else
      puts "auth success".colorize(:green) if @@debug
    end
  end

  ### list all available repos
  def list(search_key = nil)
    result = self.class.get("/_catalog")
    result['repositories'].each{ |repo|
        puts repo if search_key.nil? || repo.include?(search_key)
    }
  end

  ### search for a specific repo using a key ( wildcard )
  def search(search_key)
    list(search_key)
  end

  ### delete
  def delete_image(image_name, tag)
    puts "NOT SUPPORTED YET!!!"
    puts self.class.delete("/#{image_name}/manifests/#{tag}")
  end

  ### list all tags of a repo
  def tags(repo)
    result = self.class.get("/#{repo}/tags/list")
    result['tags'].each{ |tag|
      puts tag
    }
  end
end