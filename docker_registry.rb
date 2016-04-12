#!/usr/bin/env ruby

require 'optparse'
require 'colorize'
require 'pp'

require_relative "DockerRegistryRequest"

# our defaults / defines
options = {:user => nil,:password => nil, :domain => nil, :debug => false}
ops = ['list','search', 'tags', 'delete']

# define our options and help
OptionParser.new do |opts|
  opts.banner = "Usage: registry.rb [options]"

  opts.on("-u", "--user USER", "optional, user to login") do |v|
    options[:user] = v
  end
  opts.on("-p", "--password PASSWORD", "optional, password to login") do |v|
    options[:password] = v
  end
  opts.on("--domain DOMAIN", "Set this to override the domain you defined in ~./docker_registry.yml") do |v|
    options[:domain] = v
  end
  opts.on("-d", "--debug", "debug mode") do |v|
    options[:debug] = v
  end
  opts.on("-h", "--help", "Prints this help") do

    puts opts
    puts "\nArguments:"
    puts "<registry-domain> <operation> <value(optional)>".colorize(:green)
    puts "\nif you have set domain in ~/.docker_registry.yml you can ease it up like this:"
    puts "<operation> <value(optional)>".colorize(:green)

    puts "\nOperations:"
    puts "list: list all available repositorys"
    puts "search <key>: search for a repository"
    puts "tag <repo-name>: list all tags of a repository"
    exit
  end
end.parse!

# try to load values from tour configuration. Those get superseeded by the arguments though
begin
  config = YAML::load(File.read(File.join(ENV['HOME'], '.docker_registry.yml')))
  if options[:debug]
    puts "Found config:".colorize(:blue)
    pp config
  end

  options[:domain] = config['domain'] if config['domain'] && !options[:domain]
  options[:user] = config['user'] if config['user'] && !options[:user]
  options[:password] = config['password'] if config['password'] && !options[:password]
rescue
  # just no config, move on
  puts "No config found in ~/.docker_registry.yml . Create it and add domain:<> and optional user/password to avoid adding any arguments".colorize(:light_white)
  if !ARGV[0]
    puts "The first argument should be your registry domain without schema (HTTPS mandatory), optional with :port".colorize(:red)
    exit 1
  else
    options[:domain]  = ARGV.shift
  end
end

# ensure a operation is set. Be aware, we used shift up there - so we always stick with 0
if !ARGV[0]
  puts "Define the operation: #{ops.join(', ')}".colorize(:red)
  exit 1
else
  if !ops.include?(ARGV[0])
    puts "This operation is yet not implemented. Select on of:  #{ops.join(', ')}".colorize(:red)
    exit 1
  end

  op = ARGV.shift
end

# print out some informations debug mode
if options[:debug]
  pp options
  puts "Operation: #{op}".colorize(:blue)
end

# configure our request handler
registry = DockerRegistryRequest.new(options[:domain], options[:user], options[:password], options[:debug])

# run the operations, which can actually have different amounts of mandatory arguments
case op
  when 'delete'
    key = ARGV.shift
    registry.delete_image(key)
  when 'list'
    registry.list
  when 'search'
    if !ARGV[0]
      puts "Please define a search key"
      exit 1
    else
      key = ARGV.shift
      registry.search(key)
    end
  when 'tags'
    if !ARGV[0]
      puts "Please define a repo name"
      exit 1
    else
      repo = ARGV.shift
      registry.tags(repo)
    end
end
