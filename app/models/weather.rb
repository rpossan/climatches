class Weather < ApplicationRecord
  has_many :forecasts

  CELSIUS_FACTOR = 273.15

  def celsius
    (temperature - CELSIUS_FACTOR).to_i
  end

  def forecast_celsius(datetime=nil)
    return celsius if forecasts.size == 0
    if datetime.nil?
      temperature = celsius
    else
      temperature = forecasts.where(["date > ?", datetime]).order(:date).first.degrees / CELSIUS_FACTOR
    end
    temperature.to_i
  end

  def average_degrees(date=Date.today)
    forecasts.where(date: date).average(:degrees).to_i
  end
end
