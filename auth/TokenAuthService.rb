class TokenAuthService
  @@requestToBeAuthed = nil
  def initialize(requestToBeAuthed)
    @@requestToBeAuthed = requestToBeAuthed
  end

  def tokenAuth(responseToBeAuthed)
    # retrieve how we will contact the token service
    auth_description = responseToBeAuthed.headers()['www-authenticate']
    options = {
        :query => {
        }
    }
    # get the url
    m = /Bearer realm="(?<url>[^"]+)"/.match(auth_description)
    url = m['url']

    # get the service we will generate the tokens for
    m = /service="(?<service>[^"]+)"/.match(auth_description)
    if(m)
      options[:query][:service] = m['service']
    end
    # the scope, importent if scopes are used in the token service
    # this is not always set
    m = /scope="(?<scope>[^"]+)"/.match(auth_description)
    if(m)
      options[:query][:scope] = m['scope']
    end

    unless(url)
      puts "Could not extract auth information for Bearer token".colorize(:red) if @@debug
      throw "Could not extract auth information for Bearer token"
    end
    # get the bearer token
    response = HTTParty.get(url,options)

    throw "Failed to authenticate, code #{response.code}" unless response.code == 200 || response.has_key?('token')
    # decorate our request object
    @@requestToBeAuthed.class.headers['Authorization'] = "Bearer #{response['token']}"
  end
end