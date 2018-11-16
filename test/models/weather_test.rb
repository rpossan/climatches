require 'test_helper'

class WeatherTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.start
    @campinas = weathers(:campinas)
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_new_weather
    assert_instance_of Weather, @campinas
  end

  def test_to_celcius
    @campinas.temperature = 303
    assert_equal 29, @campinas.celcius
  end

  def test_average_degrees
    weather = WeatherService.new.forecast_by(city: "campinas")
    assert_equal Integer, weather.average_degrees.class
    assert weather.average_degrees > 0
  end

end
