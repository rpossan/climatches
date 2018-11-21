class Weather < ApplicationRecord
  has_many :forecasts
  def celcius
    (temperature - 273.15).to_i
  end

  def average_degrees(date=Date.today)
    forecasts.where(date: date).average(:degrees).to_i
  end
end
