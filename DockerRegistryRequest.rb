#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'httparty'
require 'yaml'
require 'pp'

require_relative 'auth/TokenAuthService'

class DockerRegistryRequest
  include HTTParty
  format :json
  headers 'Content-Type' => 'application/json'
  headers 'Accept' => 'application/json'
  @@debug = false

  def initialize(domain, user = nil, pass = nil, debug = false)
    @@debug = debug
    self.class.base_uri "https://#{domain}/v2"
    handle_preauth(domain, user, pass)
  end

  def handle_preauth(domain, user = nil, pass = nil)
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
      end
    end
  end

  ### check if the login actually will succeed
  def authenticate(response)
      headers = response.headers()
      begin
        if(headers.has_key?('www-authenticate'))
        auth_description = headers['www-authenticate']
        if(auth_description.match('Bearer realm='))
          authService = TokenAuthService.new()
          authService.auth(response, self)
        end
        end
      rescue Exception
          puts "Authentication failed".colorize(:red)
      end
  end

  def login_strategy_bearer_token(auth_description)

  end

  ### list all available repos
  def list(search_key = nil)
    response = self.class.get("/_catalog")
    case (response.code)
      when 200
        # just continue
      when 401
        authenticate(response)
        response = self.class.get("/_catalog")
      else
    end
    unless response.code == 200
      throw "Could not finish request, status #{response.code}"
    end

    response['repositories'].each{ |repo|
      puts repo if search_key.nil? || repo.include?(search_key)
    }
  end

  ### search for a specific repo using a key ( wildcard )
  def search(search_key)
    list(search_key)
  end

  ### delete, identified by image name and tag
  ### @see https://docs.docker.com/registry/spec/api/#deleting-an-image
  def delete_image(image_name, tag)
    # be sure to enabel storage->delete->true in your registry, see https://github.com/docker/distribution/blob/master/docs/configuration.md

    # fetch digest
    digest = digest(image_name,tag)
    if !digest
      puts "Could not find digest from tag #{tag}".colorize(:red)
      exit 1
    end
    result =  self.class.delete("/#{image_name}/manifests/#{digest}")
    if (result.code != 202)
      puts "Could not delete image".colorize(:red)
      exit 1
    end
  end

  ### returns the digest for a tag
  ### @see https://docs.docker.com/registry/spec/api/#pulling-an-image
  def digest(image_name, tag)
    result = self.class.get("/#{image_name}/manifests/#{tag}")

    if (result.code != 200)
      puts "Could not find digest for image #{image_name} with tag #{tag}".colorize(:red)
      exit 1
    end
    return result.headers['docker-content-digest']
  end

  ### list all tags of a repo
  def tags(repo)
    result = self.class.get("/#{repo}/tags/list")
    result['tags'].each{ |tag|
      puts tag
    }
  end
end