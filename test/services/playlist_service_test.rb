require 'test_helper'
require "database_cleaner"
DatabaseCleaner.strategy = :transaction

class PlaylistServiceTest < Minitest::Test

  def setup
    DatabaseCleaner.start
    @playlist_service = PlaylistService.new
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_new_service
    assert_instance_of PlaylistService, @playlist_service
  end

  # def test_party
  #   pl = @playlist_service.get_by_celcius(30)
  #   refute_equal pl.name, "party"
  #   pl = @playlist_service.get_by_celcius(31)
  #   asert_equal pl.name, "party"
  # end

  # def test_pop
  #   pl = @playlist_service.get_by_celcius(14)
  #   refute_equal pl.name, "pop"
  #   pl = @playlist_service.get_by_celcius(31)
  #   refute_equal pl.name, "pop"
  #   pl = @playlist_service.get_by_celcius(18)
  #   asert_equal pl.name, "pop"
  # end

  # def test_rock
  #   pl = @playlist_service.get_by_celcius(9)
  #   refute_equal pl.name, "rock"
  #   pl = @playlist_service.get_by_celcius(15)
  #   refute_equal pl.name, "rock"
  #   pl = @playlist_service.get_by_celcius(12)
  #   asert_equal pl.name, "rock"
  # end

  # def test_classical
  #   pl = @playlist_service.get_by_celcius(10)
  #   refute_equal pl.name, "classical"
  #   pl = @playlist_service.get_by_celcius(9)
  #   asert_equal pl.name, "classical"
  # end

end