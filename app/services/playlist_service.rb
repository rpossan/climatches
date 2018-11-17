class PlaylistService

  attr_accessor :client_id, :client_secret
  attr_reader :logged

  CATEGORIES = ["classical", "pop", "rock", "party"]

  def initialize(client_id=nil, client_secret=nil)
    @client_id = ENV['SPOTIFY_CLIENT_ID'] if @client_id.nil?
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
    category = "pop" if (10..14).include? degrees
    category = "rock" if (15..30).include? degrees
    category = "party" if degrees > 30
    Playlist.where(category: category)
  end

  def self.fetch!
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
      rescue
        puts "Can't reach server. Using cache!"
        raise ActiveRecord::Rollback
      end
    end
  end

end