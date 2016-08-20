class BasicAuthService
  @requestToBeAuthed = nil
  def initialize(requestToBeAuthed)
    @requestToBeAuthed = requestToBeAuthed
  end
  def byCredentials(user, pass)
    @requestToBeAuthed.class.basic_auth user, pass
  end

  def byToken
    # load the docker config and see, if the domain is included there - reuse the auth token
    config = nil
    config_path = File.join(ENV['HOME'], '.docker/config.json')
    if File.exist?(config_path)
      config = JSON.parse(File.read(config_path))
    end

    if !config.nil? && config['auths'].key?(@requestToBeAuthed.registry_domain) && config['auths'][@requestToBeAuthed.registry_domain]
      pp 'Using existing token from config.json not the keychain. Do not do that!!'.red
      # decorate our request object
      # set the Authorization header directly, since it is already base64 encoded
      token = config['auths'][@requestToBeAuthed.registry_domain]['auth']
      if !token
        pp config if @@debug
        throw 'No auth token found for this domain'
      end
      @requestToBeAuthed.class.headers['Authorization'] = "Basic #{token}"
    else
      use_keychain_auth
    end
  end

  def use_keychain_auth
    osx_cred_entry = Keychain.internet_passwords.where(:path => @requestToBeAuthed.registry_domain).first
    if osx_cred_entry.nil?
      puts "Not found any keychain entry for registry #{@requestToBeAuthed.registry_domain}, please auth using: docker login #{@requestToBeAuthed.registry_domain}".red if @debug
      throw 'Keychain entry not found'
    elsif @debug
      puts "Found user '#{osx_cred_entry.account}' in keychain".white
    end
    # we do nto use basic_auth here, since we cannot override it later if  we need to use Bearer auth
    @requestToBeAuthed.class.headers['Authorization'] = @requestToBeAuthed.class.basic_encode(osx_cred_entry.account, osx_cred_entry.password)
  end
end