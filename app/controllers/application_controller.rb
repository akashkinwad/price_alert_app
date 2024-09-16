class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = request.headers['Authorization']
    begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      @current_user = User.find(decoded_token['user_id'])
    rescue JWT::DecodeError
      render json: { errors: 'Invalid token' }, status: :unauthorized
    end
  end

  def pagination_meta(objects)
    {
      current_page: objects.current_page,
      next_page: objects.next_page,
      prev_page: objects.prev_page,
      total_pages: objects.total_pages,
      total_count: objects.total_count
    }
  end
end
