every 6.hours do
  runner "PlaylistsJob.perform"
end

every 6.hours do
  runner "WeatherForecastJob.perform"
end