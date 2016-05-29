class BasicAuthService

  @@requestToBeAuthed = nil
  def initialize(requestToBeAuthed)
    @@requestToBeAuthed = requestToBeAuthed
  end
  def byCredentials(user, password)
    @@requestToBeAuthed.class.basic_auth user, pass
  end

  def byToken()
    # load the docker config and see, if the domain is included there - reuse the auth token
    config = JSON.parse(File.read(File.join(ENV['HOME'], '.docker/config.json')))
    token = config['auths'][domain]['auth']
    if(!token)
      pp config if @@debug
      throw('No auth token found for this domain')
    end

    pp "Using existing token from config.json #{token}" if @@debug

    # decorate our request object
    # set the Authorization header directly, since it is already base64 encoded
    @@requestToBeAuthed.class.headers['Authorization'] = "Basic #{token}"
  end
end