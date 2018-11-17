class PlaylistService

  attr_accessor :client_id, :client_secret
  attr_reader :logged

  CATEGORIES = ["classical", "pop", "rock", "party"]

  def initialize(client_id=nil, client_secret=nil)
    @client_id = ENV['SPOTIFY_CLIENT_ID'] if client_id.nil?
    @client_secret = ENV['SPOTIFY_CLIENT_SECRET'] if @client_secret.nil?
    begin
      RSpotify.authenticate("#{@client_id}", "#{@client_secret}")
      @logged = true
    rescue
      puts "Can't reach server. Using cache!"
      @logged = false
    end
  end

  def get_by_celsius(degrees, force=false)
    fetch! if force && @logged
    category = "classical" if degrees < 10
    category = "rock" if (10..14).include? degrees
    category = "pop" if (15..30).include? degrees
    category = "party" if degrees > 30
    Playlist.where(category: category)
  end

  def fetch!
    ActiveRecord::Base.transaction do
      begin
        Playlist.destroy_all
        CATEGORIES.each do |cat|
          RSpotify::Category.find(cat).playlists.each do |pl|
            pl = Playlist.new(category: cat)
            pl.tracks = pl.tracks.collect{|t| {name: t.name} }
            pl.save
          end
        end
        true
      rescue
        puts "Can't reach server. Using cache!"
        ActiveRecord::Rollback
        false
      end
    end
  end

end