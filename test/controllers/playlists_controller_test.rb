require 'test_helper'

class PlaylistsControllerTest < ActionDispatch::IntegrationTest

  def setup
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  def test_playlist
    get "/v1/playlists/campinas"
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  def test_playlist_city_not_found
    get "/v1/playlists/ronaldo"
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  def test_playlist_by_gps
    get "/v1/playlists/-22.927971/-47.037842"
    assert_response :success
    assert_equal "application/json", response.content_type
  end

end