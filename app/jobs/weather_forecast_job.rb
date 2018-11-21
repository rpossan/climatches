class WeatherForecastJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Weather.all.each do |w|
      begin
        WeatherService.new.forecast_by(city: w.city)
      rescue
        puts "City #{w.city} not found!"
      end
    end
  end
end
