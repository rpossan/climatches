class V1::PlaylistsController < ApplicationController

  def index
    begin
      force_fetch = (Rails.env == "test") # just for test environment
      filter = parse_filter
      w_service = WeatherService.new
      weather = w_service.find_by(filter)
      if weather
        pl_service = PlaylistService.new
        degrees = weather.forecast_celsius Time.now
        playlist = pl_service.get_by_celsius(degrees, force_fetch)
        @playlist = { forecast_degrees: degrees, category: playlist.category, total: playlist.tracks.size, status: "success" }
        @playlist[:tracks] = playlist.tracks.map{|t| t.name }
      else
        @playlist = { status: "error", message: "City not found!" }
      end
      render json: @playlist, status: :ok
    rescue => error
     render json: { status: "error", message: error.message.to_s }, status: :error
    end
  end

  private
  def parse_filter
    if params[:lat].present? && params[:lon].present?
      lat = params[:lat].to_f.round(2) # Open Weather API precision
      lon = params[:lon].to_f.round(2) # Open Weather API precision
      latlon = { lat: lat, lon: lon }
      filter = { latlon: latlon }
    else
      filter = { city: params[:id].downcase }
    end
    filter
  end

end
