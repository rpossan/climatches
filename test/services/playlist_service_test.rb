require 'test_helper'
require "database_cleaner"
DatabaseCleaner.strategy = :transaction

class PlaylistServiceTest < Minitest::Test

  def setup
    DatabaseCleaner.start
    @playlist_service = PlaylistService.new
    @playlist_service.fetch!
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_offline
    assert_equal false, PlaylistService.new("test", "test").logged
    assert_equal true, PlaylistService.new("abc", "xyz").fetch!
  end

  def test_new_service
    assert_instance_of PlaylistService, @playlist_service
  end

  def test_party
    pl = @playlist_service.get_by_celsius(29)
    refute_equal pl.name, "party"
    pl = @playlist_service.get_by_celsius(31)
    assert_equal pl.first.category, "party"
  end

  def test_pop
    pl = @playlist_service.get_by_celsius(14)
    refute_equal pl.first.category, "pop"
    pl = @playlist_service.get_by_celsius(31)
    refute_equal pl.first.category, "pop"
    pl = @playlist_service.get_by_celsius(18)
    assert_equal pl.first.category, "pop"
  end

  def test_rock
    pl = @playlist_service.get_by_celsius(9)
    refute_equal pl.first.category, "rock"
    pl = @playlist_service.get_by_celsius(15)
    refute_equal pl.first.category, "rock"
    pl = @playlist_service.get_by_celsius(12)
    assert_equal pl.first.category, "rock"
  end

  def test_classical
    pl = @playlist_service.get_by_celsius(10)
    refute_equal pl.first.category, "classical"
    pl = @playlist_service.get_by_celsius(9)
    assert_equal pl.first.category, "classical"
  end

end