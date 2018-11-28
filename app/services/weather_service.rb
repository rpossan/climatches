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

  # Find a weather, forecast or create a new one by city or latlon
  def find_by(latlon:{}, city:"", forecast:false)
    # Set class variable @filters using gps or city params
    set_filter!(city, latlon[:lat], latlon[:lon])
    # Load or create new weather by city, gps or get from forecast
    cached_weather = load_or_create!

    # Generates forecast if it forced. Job will generate this in the next execution
    generate_forecast_for cached_weather if forecast
    cached_weather
  end

  private
  # Request to weather API with the filters or use forecast
  def request_weather
    begin
      response = self.class.get("/weather", @filters)
    rescue => error
      puts error.message
      error_message = "Error: #{error.message}" +
      " - Could not use cache for parameters: " +
      "[City: #{@filters[:query][:q]}, " +
      "Lat: #{@filters[:query][:lat]}, Lon: #{@filters[:query][:lon]}]"
      raise error_message
    end
    # Parse response
    parse! response
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

  def load_or_create!
    # Find Weather by the given city or gps params on filter
    if @filters[:query][:q].nil?
      cached_weather = Weather.where(
        lat: @filters[:query][:lat],
        lon: @filters[:query][:lon]).first
    else
      cached_weather = Weather.where(city: @filters[:query][:q]).first
    end
    unless cached_weather
      data = request_weather
      # Now, try to find by city from the reponse of API in case GPS not found in cache, but city found
      cached_weather = Weather.where(city: data[:city].downcase).first_or_initialize
      cached_weather.temperature = data[:temperature]
      cached_weather.lat = data[:lat]
      cached_weather.lon = data[:lon]
      cached_weather.city_id = data[:city_id]
      cached_weather.save # Create or update degrees from API
    end

    cached_weather
  end

  def generate_forecast_for(weather)
    ActiveRecord::Base.transaction do
      begin
        weather.forecasts.destroy_all
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
      rescue => error
        puts error.message
        ActiveRecord::Rollback
        raise error.message
      end
    end
  end

  def set_filter!(city, lat, lon)
    if city.empty?
      @filters[:query].merge!({lat: lat, lon: lon})
    else
      @filters[:query].merge!({q: city})
    end
    @filters
  end

  # Alias to be used by find_by or weather_by, as the forecast_by
  alias weather_by find_by
end