Rails.application.routes.draw do
  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/ronaldo; version=1"}) do
    match '/playlists/:id' => 'foos#index', :via => :get
  end
end
