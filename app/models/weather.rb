class Weather < ApplicationRecord
  has_many :forecasts
  def celcius
    (temperature - 273.15).to_i
  end
end
