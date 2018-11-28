require 'sidekiq/web'
Rails.application.routes.draw do 
  mount Sidekiq::Web => '/sidekiq'
  api_version(:module => "V1", :path => {:value => "v1"}) do
    match '/playlists/:id' => 'playlists#index', :via => :get
    match "/playlists/:lat/:lon" => 'playlists#index',
    :constraints => {
      :lat => /\-?\d+(.\d+)?/, :lon => /\-?\d+(.\d+)?/,
      :range => /\d+/}, :via => :get
  end
end
