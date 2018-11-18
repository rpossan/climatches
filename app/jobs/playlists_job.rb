class PlaylistsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    PlaylistService.new.fetch!
  end
end
