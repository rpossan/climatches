class V1::PlaylistsController < ApplicationController

  def index
    force_fetch = (Rails.env == "test")
    param = params[:id]
    w_service = WeatherService.new
    weather = w_service.find_by(city: "campinas")
    pl_service = PlaylistService.new
    @playlist = pl_service.get_by_celsius(weather.celcius)
    render json: @playlist.tracks, status: :ok
  end

end
