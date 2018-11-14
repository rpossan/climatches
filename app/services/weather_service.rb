class WeatherService
  include HTTParty
  base_uri "#{ENV['OWM_ENDPOINT']}/#{ENV['OWM_VERSION']}"

  attr_accessor :id, :name, :temperature

  def initialize(appid=nil)
    appid = ENV['OWM_APPID'] if appid.nil?
    @filters = { query: { appid: appid } }
  end

  def find_by(latlon:{}, city:"")
    unless latlon.empty? && city.empty?
      @filters = get_by_city(city) unless city.empty?
      @filters = get_by_latlon(latlon[:lat], latlon[:lon]) unless latlon.empty?
    end
    response = self.class.get("/weather", @filters)
    data = parse! response
    Weather.create data
  end

  private
  def get_by_city(city)
    @filters[:query].merge!({q: city})
    @filters
  end

  def get_by_latlon(lat, lon)
    @filters[:query].merge!({lat: lat, lon: lon})
    @filters
  end

  def parse! data
    data = data.parsed_response
    raise data["message"] if data["cod"] != 200
    {
      city: data["name"],
      city_id: data["id"],
      temperature: data["main"]["temp"],
      lat: data["coord"]["lat"],
      lon: data["coord"]["lon"]
    }
  end
end