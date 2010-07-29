TestApp::Application.routes.draw do
  
  resources :cities do
    collection do
      get :ajax
    end
  end  
  
  resources :people do
    collection do
      get :ajax
    end
  end
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
