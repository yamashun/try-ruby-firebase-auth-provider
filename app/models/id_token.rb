class IdToken
  @@private_key = OpenSSL::PKey::RSA.new File.read('config/private_key.pem'), "vP/pL9hJngjjgw="

  class << self
    def generate_id_token(user, client, scope)
      payload = {
        iss: "https://example.com",
        sub: user.id,
        aud: client.client_id,
        exp: 5.minutes.from_now.to_i,
        iat: Time.current.to_i
      }

      payload[:email] = user.email if scope.split(" ").include?("email")

      # ref: https://github.com/jwt/ruby-jwt#add-custom-header-fields
      JWT.encode(payload, @@private_key, 'RS256', { typ: 'JWT', kid: 'authserver' })
    end
  end
end
