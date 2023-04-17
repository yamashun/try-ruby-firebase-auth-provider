class AuthorizationController < ApplicationController
  def authorize
    Rails.logger.info(params)
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
    return render json: { message: "Unauthorized" }, status: :unauthorized  if request.blank? || request.expires_at < Time.current

    user = User.find_by(email: params[:email])&.authenticate(params[:password])
    if user.blank?
      # TODO: ログイン失敗時の処理
      render json: { message: "Unauthorized" }, status: :unauthorized
    else
      code = SecureRandom.hex(16)
      AuthorizationCode.create!(code: code, expires_at: 30.days.from_now)
      redirect_to build_url(request, code)
    end
  end

  def token
    # TODO: 実装
  end

  def test_page
    head :ok
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
end
