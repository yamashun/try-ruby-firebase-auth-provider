class OpenidConfigurationController < ApplicationController
  def show
    # TODO: jwks_uri
    render json: {
      "issuer": Settings.root_url,
      "authorization_endpoint": "#{Settings.root_url}/approve",
      "token_endpoint": "#{Settings.root_url}/token",
      "userinfo_endpoint": "#{Settings.root_url}/userinfo",
      "scopes_supported": ["openid", "profile", "email"],
      "response_types_supported": ["code"],
      "subject_types_supported": ["public"], # 本来はpairwiseの方がいい
      "id_token_signing_alg_values_supported": ["ES256"],
      "code_challenge_methods_supported": ["S256"]
    }
  end
end
