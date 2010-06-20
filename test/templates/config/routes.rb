TestApp::Application.routes.draw do |map|
  
  resources :cities do
      get :ajax, :on => :collection
  end  
  resources :people do
      get :ajax, :on => :collection
  end
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
