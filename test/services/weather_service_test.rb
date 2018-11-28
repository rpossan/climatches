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

  def test_find_by_city
    weather = @weather_service.find_by(city: "campinas")
    assert_equal weather.city, "campinas"
    assert_equal Integer, weather.temperature.class
  end

  def test_weather_by_city
    weather = @weather_service.weather_by(city: "campinas")
    assert_equal weather.city, "campinas"
    assert_equal Integer, weather.temperature.class
  end

  def test_weather_by_latlon
    weather = @weather_service.weather_by(latlon: @coords)
    assert_equal weather.city, "campinas"
    assert_equal Integer, weather.temperature.class
  end

  def test_weather_not_found
    error = assert_raises(RuntimeError){ @weather_service.weather_by(city: "ABX") }
    assert_equal error.message, 'city not found'
  end

  def test_forecast
    weather = @weather_service.forecast_by(city: "campinas")
    assert_equal weather.city, "campinas"
    assert weather.forecasts.size > 0
  end

  # def test_forecast_not_found
  #   assert_raises(RuntimeError){ @weather_service.forecast_by(city: "ABX") }
  # end

end