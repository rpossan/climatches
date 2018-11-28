class WeatherForecastJob < ApplicationJob
  queue_as :sidekiq

  def perform(*args)
    Weather.all.each do |w|
      WeatherService.new.forecast_by(city: w.city)
    end
  end

end
