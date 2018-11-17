Rails.application.routes.draw do
  api_version(:module => "V1", :path => {:value => "v1"}) do
    match '/playlists/:id' => 'playlists#index', :via => :get
  end
end
