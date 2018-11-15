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

end
