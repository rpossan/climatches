# config/initializers/her.rb
endpoint = "#{ENV['OWM_ENDPOINT']}/#{ENV['OWM_VERSION']}/"
Her::API.setup url: endpoint do |ep|
  # Request
  ep.use Faraday::Request::UrlEncoded

  # Response
  ep.use Her::Middleware::DefaultParseJSON

  # Adapter
  ep.use Faraday::Adapter::NetHttp
end