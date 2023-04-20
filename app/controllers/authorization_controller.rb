class AuthorizationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[token]

  def authorize
    @client = Client.find_by(client_id: params[:client_id])
    if @client.blank? || !valid_redirect_uri?(@client) || !valid_scope?(@client)
      return render json: { message: "Unauthorized" }, status: :unauthorized
    end

    @request_id = SecureRandom.hex(16)
    Request.create!(
      request_id: @request_id,
      expires_at: 5.minutes.from_now,
      client: @client,
      state: params[:state]
    )
  end

  def approve
    request = Request.find_by(request_id: params[:request_id])
    return render json: { message: "Unauthorized" }, status: :unauthorized if request.blank? || request.expires_at < Time.current

    user = User.find_by(email: params[:email])&.authenticate(params[:password])
    if user.blank?
      # TODO: ログイン失敗時の処理
      render json: { message: "Unauthorized" }, status: :unauthorized
    else
      code = SecureRandom.hex(16)
      AuthorizationCode.create!(code: code, request: request, user: user, expires_at: 15.minutes.from_now)
      redirect_to build_url(request, code)
    end
  end

  def token
    auth = extract_client_credentials
    return render json: { error: "invalid_request" }, status: :bad_request if auth.blank?

    client = Client.find_by(client_id: auth[:client_id])
    if client.blank? || client.client_secret != auth[:client_secret] || params[:grant_type] != "authorization_code"
      return render json: { error: "invalid_request" }, status: :bad_request
    end

    code = AuthorizationCode.find_by(code: params[:code])
    return render json: { error: "invalid_request" }, status: :bad_request if code.blank? || code.expires_at < Time.current

    access_token = SecureRandom.hex(16)
    AccessToken.create!(token: access_token, user: code.user, client_id: code.request.client.client_id, scope: code.request.client.scope, expires_at: 30.days.from_now)

    # TODO: スコープをどこから取るか見直す
    client_scope = code.request.client.scope
    token_response = {
      access_token: access_token,
      token_type: 'Bearer',
      scope: client_scope,
      expires_in: 3600
    }

    if client_scope.split(" ").include?("openid")
      token_response[:id_token] = IdToken.generate_id_token(code.user, code.request.client, client_scope)
    end

    code.destroy!

    response.headers['Cache-Control'] = 'no-store'
    response.headers['Pragma'] = 'no-cache'

    render json: token_response
  end

  def test_page
    result = ActionController::HttpAuthentication::Basic.decode_credentials(request)

    render json: { message: result }
  end

  private

  def valid_redirect_uri?(client)
    # TODO: 複数対応のreqirect_uriへの対応
    client.redirect_uris == params[:redirect_uri]
  end

  def valid_scope?(client)
    params_scope = params[:scope].split(' ')
    client.scope.split(' ').all? { |scope| scope.in?(params_scope) }
  end

  def build_url(request, code)
    # TODO: 複数のredirect_uriへの対応
    uri = URI.parse(request.client.redirect_uris)
    uri.query = {
      code: code,
      state: request.state
    }.to_query
    uri.to_s
  end

  def extract_client_credentials
    credentials = nil
    if request.headers['Authorization'].present?
      credentials = decode_client_credentials(request.headers['Authorization'])
    elsif params[:client_id].present?
      return nil if credentials.present?

      credentials = {
        client_id: params[:client_id],
        client_secret: params[:client_secret]
      }
    end

    credentials
  end

  def decode_client_credentials(authorization)
    credentials = ActionController::HttpAuthentication::Basic.decode_credentials(request).split(':')
    {
      client_id: credentials[0],
      client_secret: credentials[1]
    }
  end

  def build_id_token(user, client, scope)
    payload = {
      iss: "https://example.com",
      sub: user.id, # 本当はclient毎にsubを発行する必要があるが検証用のためuser.idをそのまま使う
      aud: client.client_id,
      exp: 5.minutes.from_now.to_i,
      iat: Time.current.to_i
    }

    payload[:email] = user.email if scope.split(" ").include?("email")

    # ref: https://github.com/jwt/ruby-jwt#add-custom-header-fields
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'RS256', { typ: 'JWT', kid: 'authserver' })
  end
end
