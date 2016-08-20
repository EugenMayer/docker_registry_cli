#!/usr/bin/ruby

require_relative '../requests/DockerRegistryRequest'

class DockerRegistryCommand < DockerRegistryRequest
  ### list all available repos
  def list(search_key = nil)
    response = send_get_request("/_catalog")
    if response['repositories'].nil?
      puts 'no repositories found'
      exit 1
    else
      response['repositories'].each { |repo|
        puts repo if search_key.nil? || repo.include?(search_key)
      }
    end
  end

  ### search for a specific repo using a key ( wildcard )
  def search(search_key)
    list(search_key)
  end

  ### delete an image, so all its tags
  ### @see https://docs.docker.com/registry/spec/api/#deleting-an-image
  def delete_image(image_name)
    # be sure to enabel storage->delete->true in your registry, see https://github.com/docker/distribution/blob/master/docs/configuration.md
    tags = tags(image_name)
    if tags.nil?
      puts "Image #{image_name} has no current tags, nothing to delete".red
      exit
    end
    tags.each { |tag|
      begin
        puts "Deleting tag : #{tag}"
        delete_tag(image_name, tag)
        puts 'success'.green
      rescue
        puts 'failed'.red
      end
    }

  end


  ### delete a tag, identified by image name and tag
  ### @see https://docs.docker.com/registry/spec/api/#deleting-an-image
  def delete_tag(image_name, tag)
    # be sure to enabel storage->delete->true in your registry, see https://github.com/docker/distribution/blob/master/docs/configuration.md

    # fetch digest
    digest = digest(image_name, tag)
    unless digest
      puts "Could not find digest from tag #{tag}".colorize(:red)
      exit 1
    end
    result = send_delete_request("/#{image_name}/manifests/#{digest}")

    unless result.code == 202
      puts "Could not delete tag #{tag}".colorize(:red)
      exit 1
    end

    #result = send_delete_request("/#{image_name}/blobs/#{digest}")
    #unless result.code == 202
    #  puts "Could not delete blob from digest #{digest}".colorize(:red)
    #  exit 1
    #end
  end

  ### list all tags of a repo
  def tags(repo)
    result = send_get_request("/#{repo}/tags/list")
    return result['tags']
  end
end