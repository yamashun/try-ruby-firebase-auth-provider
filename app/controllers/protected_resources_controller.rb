class ProtectedResourcesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def userinfo
    @access_token = find_access_token
    return head :unauthorized if @access_token.nil? || @access_token.scope.split(' ').exclude?('openid')

    render json: build_user_info_response
  end

  private

  def find_access_token
    if request.headers['Authorization'].present?
      authenticate_or_request_with_http_token do |token, _options|
        AccessToken.find_by(token: token)
      end
    else
      AccessToken.find_by(token: params[:access_token])
    end
  end

  def build_user_info_response
    # scopeに合わせてユーザー情報を返す
    # openidは常に含まれる前提
    response = {
      sub: @access_token.user.id,
    }
    scope = @access_token.scope.split(' ')

    response[:name] = @access_token.user.name if 'profile'.in?(scope)
    response[:email] = @access_token.user.email if 'email'.in?(scope)

    response
  end
end
