class WeatherService
  include HTTParty
  include HTTParty::DryIce
  base_uri "#{ENV['OWM_ENDPOINT']}/#{ENV['OWM_VERSION']}"
  cache Rails.cache

  attr_accessor :appid

  def initialize(appid=nil)
    appid = ENV['OWM_APPID'] if appid.nil?
    @filters = { query: { appid: appid } }
  end

  def forecast_by(latlon:{}, city:"")
    find_by(latlon: latlon, city:city, forecast: true)
  end

  def find_by(latlon:{}, city:"", forecast:false)
    city = city.downcase unless city.empty?
    cached_weather = Weather.where(city: city).or(
      Weather.where(lat: latlon[:lat], lon: latlon[:lon])
    ).limit(1).first

    unless cached_weather
      unless latlon.empty? && city.empty?
        @filters = get_by_city(city) unless city.empty?
        @filters = get_by_latlon(latlon[:lat], latlon[:lon]) unless latlon.empty?
      end
      begin
        response = self.class.get("/weather", @filters)
        data = parse! response
        cached_weather = Weather.create data
      rescue => error
        return false
      end
    end
    generate_forecast_for cached_weather if forecast
    return cached_weather
  end


  private

  def generate_forecast_for(weather)
    begin
      @filters[:query].merge!({q: weather.city})
      response = self.class.get("/forecast", @filters)
      response.parsed_response["list"].each do |forecast|
        atts = {
          weather_id: weather.id,
          date: forecast["dt_txt"],
          degrees: forecast["main"]["temp"]
        }
        Forecast.where(atts).first_or_create
      end
    rescue
      puts "Can't reach server! Using cache!"
    end
  end

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
      city: data["name"].downcase,
      city_id: data["id"],
      temperature: data["main"]["temp"],
      lat: data["coord"]["lat"],
      lon: data["coord"]["lon"]
    }
  end

  alias weather_by find_by
end