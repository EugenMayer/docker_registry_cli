require 'keychain'
require 'colorize'

class TokenAuthService
  @debug
  @requestToBeAuthed = nil
  def initialize(requestToBeAuthed)
    @requestToBeAuthed = requestToBeAuthed
    @debug = @requestToBeAuthed.is_debug
  end

  def tokenAuth(responseToBeAuthed)
    # retrieve how we will contact the token service
    auth_description = responseToBeAuthed.headers['www-authenticate']
    options = {
        :query => {
        }
    }
    # get the url
    m = /Bearer realm="(?<url>[^"]+)"/.match(auth_description)
    url = m['url']

    # get the service we will generate the tokens for
    m = /service="(?<service>[^"]+)"/.match(auth_description)
    if m
      options[:query][:service] = m['service']
    end
    # the scope, important if scopes are used in the token service
    # this is not always set
    m = /scope="(?<scope>[^"]+)"/.match(auth_description)
    if m
      options[:query][:scope] = m['scope']
    end

    unless url
      puts 'Could not extract auth information for Bearer token'.colorize(:red) if @debug
      throw 'Could not extract auth information for Bearer token'
    end

    config = nil
    config_path = File.join(ENV['HOME'], '.docker/config.json')
    if File.exist?(config_path)
      config = JSON.parse(File.read(config_path))
    end

    if !config.nil? && config['auths'].key?(@requestToBeAuthed.registry_domain) && config['auths'][@requestToBeAuthed.registry_domain]
      domain_settings = config['auths'][@requestToBeAuthed.registry_domain]
      puts 'Using existing token from config.json not the keychain. Do not do that, use the keychain!'.red
      # decorate our request object
      # set the Authorization header directly, since it is already base64 encoded
      options[:headers] = {}
      options[:headers]['Authorization'] = "Basic #{domain_settings['auth']}"
    else
      # load credentials from the keychain
      puts 'getting credentials from keychain'.white if @debug
      osx_cred_entry = Keychain.internet_passwords.where(:path => @requestToBeAuthed.registry_domain).first
      if osx_cred_entry.nil?
        puts "Not found any keychain entry for registry #{@requestToBeAuthed.registry_domain}, please auth using: docker login #{@requestToBeAuthed.registry_domain}".red if @debug
        throw 'Keychain entry not found'
      elsif @debug
        puts "Found user '#{osx_cred_entry.account}' in keychain".white
      end
      # get the bearer token
      options[:basic_auth] = {username: osx_cred_entry.account, password: osx_cred_entry.password}
    end

    response = HTTParty.get(url, options)

    throw "Failed to authenticate, code #{response.code}" unless response.code == 200 || response.has_key?('token')
    # decorate our request object
    @requestToBeAuthed.class.headers['authorization'] = "Bearer #{response['token']}"
  end
end