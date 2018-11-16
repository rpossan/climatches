class PlaylistService

  attr_accessor :client_id, :client_secret

  CATEGORIES = ["classical", "pop", "rock", "party"]

  def initialize(client_id=nil, client_secret=nil)
    client_id = ENV['SPOTIFY_CLIENT_ID'] if client_id.nil?
    client_secret = ENV['SPOTIFY_CLIENT_SECRET'] if client_secret.nil?
    RSpotify.authenticate("#{client_id}", "#{client_secret}")
  end

  def get_by_celsius(degrees, force=false)
    fetch! if force
    category = "classical" if degrees < 10
    category = "pop" if (10..14).include? degrees
    category = "rock" if (15..30).include? degrees
    category = "party" if degrees > 30
    playlists = Playlist.where(category: category)
    playlists
  end

  def fetch!
    Playlist.destroy_all
    CATEGORIES.each do |cat|
      RSpotify::Category.find(cat).playlists.each do |pl|
        pl = Playlist.new(category: cat)
        pl.tracks = pl.tracks.collect{|t| {name: t.name} }
        pl.save
      end
    end
  end

end