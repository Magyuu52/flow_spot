# frozen_string_literal: true

module RequestHelpers
  def login_as(user)
    post '/login', params: { email: user.email, password: user.password }
  end

  def json_response
    JSON.parse(response.body)
  end

  def auth_header(user)
    token = JwtService.encode({ user_id: user.id })
    { 'Authorization' => "Bearer #{token}" }
  end
end
