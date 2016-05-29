class TokenAuthService
  def auth(failedResponse, requestToBeAuthed)
    auth_description = failedResponse.headers()['www-authenticate']
    options = {
        :query => {
        }
    }
    m = /Bearer realm="(?<url>[^"]+)"/.match(auth_description)
    url = m['url']
    m = /service="(?<service>[^"]+)"/.match(auth_description)
    if(m)
      options[:query][:service] = m['service']
    end
    m = /scope="(?<scope>[^"]+)"/.match(auth_description)
    if(m)
      options[:query][:scope] = m['scope']
    end

    unless(url)
      puts "Could not extract auth information for Bearer token".colorize(:red) if @@debug
      throw "Could not extract auth information for Bearer token"
    end

    response = HTTParty.get(url,options)

    throw "Failed to authenticate, code #{response.code}" unless response.code == 200

    requestToBeAuthed.class.headers['Authorization'] = "Bearer #{response['token']}"
  end
end