class V1::PlaylistsController < ApplicationController

  def index
    force_fetch = (Rails.env == "test")
    if params[:lat].present? && params[:lon]
      latlon = {lat: params[:lat], lon: params[:lon]}
      filter = { latlon: latlon }
    else
      filter = {city: params[:id]}
    end
    w_service = WeatherService.new
    weather = w_service.find_by(filter)
    pl_service = PlaylistService.new
    playlist = pl_service.get_by_celsius(weather.celcius, force_fetch)
    @playlist = { category: playlist.category, total: playlist.tracks.size }
    @playlist[:tracks] = playlist.tracks.map{|t| t.name }
    render json: @playlist, status: :ok
  end

end
