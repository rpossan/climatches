class Weather < ApplicationRecord
  def celcius
    (temperature - 273.15).to_i
  end
end
