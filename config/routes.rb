Rails.application.routes.draw do
  api_version(:module => "V1", :path => {:value => "v1"}) do
    match '/playlists/:id' => 'playlists#index', :via => :get
    match "/playlists/:lat/:lon" => 'playlists#index',
    :constraints => {
      :lat => /\-?\d+(.\d+)?/, :lng => /\-?\d+(.\d+)?/ ,
      :range => /\d+/}, :via => :get
  end
end
