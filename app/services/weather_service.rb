class WeatherService
  include HTTParty
  base_uri "#{ENV['OWM_ENDPOINT']}/#{ENV['OWM_VERSION']}"

  attr_accessor :id, :name, :temperature

  def initialize(appid=nil)
    appid = ENV['OWM_APPID'] if appid.nil?
    @options = { query: { appid: appid } }
  end

  def find_by(latlon:{}, city:"")

    # @options[:query].merge!({lat: lat, lon: lon})
    # self.class.get("/weather", @options)
  end

  def to_celsius
    temperature - 273.15
  end

  private
  def get_by_city(city)

  end

  def get_by_latlon(lat, lon)

  end


end