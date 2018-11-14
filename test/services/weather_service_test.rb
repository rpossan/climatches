require 'test_helper'

class WeatherServiceTest < Minitest::Test

  def setup
    @weather_service = WeatherService.new
  end

  def test_new_service
    assert_instance_of WeatherService, @weather_service
  end

  def test_weather_by_city
    w = @weather_service.find_by(city: "Campinas")
    assert w.city == "Campinas"
  end

  def test_weather_by_latlon
    w = @weather_service.find_by(latlon: {lat: 22, lon: 22})
    assert w.city == "Campinas"
  end

end