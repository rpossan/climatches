require 'test_helper'
require "database_cleaner"
DatabaseCleaner.strategy = :transaction

class WeatherServiceTest < Minitest::Test

  def setup
    DatabaseCleaner.start
    @weather_service = WeatherService.new
    @coords = { lon:-47.06, lat:-22.91 } # Campinas
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_new_service
    assert_instance_of WeatherService, @weather_service
  end

  def test_weather_by_city
    weather= @weather_service.find_by(city: "Campinas")
    assert weather.city == "Campinas"
  end

  def test_weather_by_latlon
    weather = @weather_service.find_by(latlon: @coords)
    assert weather.city == "Campinas"
  end

  def test_weather_not_found
    error = assert_raises(RuntimeError){ @weather_service.find_by(city: "ABX") }
    assert_equal error.message, 'city not found'
  end

end