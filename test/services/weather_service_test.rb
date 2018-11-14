require 'test_helper'

class WeatherServiceTest < Minitest::Test

  def test_new_service
    ws = WeatherService.new
    assert_instance_of WeatherService, ws
  end

end