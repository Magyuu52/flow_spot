# frozen_string_literal: true

RSpec.shared_context 'authenticated request' do
  before { login_as(user) }
end

RSpec.shared_context 'authenticated as other user' do
  before { login_as(other_user) }
end

RSpec.shared_context 'with referer' do |path_method|
  let(:referer_headers) { { 'HTTP_REFERER' => send(path_method) } }
end
