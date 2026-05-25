# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    stub_client = instance_double(GoogleMapsClient)
    allow(GoogleMapsClient).to receive(:new).and_return(stub_client)
    allow(stub_client).to receive(:geocode).and_return({ lat: 35.6762, lng: 139.6503 })
  end
end
