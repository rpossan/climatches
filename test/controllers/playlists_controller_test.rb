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

end