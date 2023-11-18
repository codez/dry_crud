# encoding: UTF-8

TestApp::Application.routes.draw do

  resources :people do
    collection do
      get :turbo
    end
  end

  get 'vips' => 'vips#index', :as => :vips

  namespace :admin do
    resources :countries do
      collection do
        get :turbo
      end

      resources :cities do
        collection do
          get :turbo
        end
      end
    end
  end

  root to: 'people#index'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible
  # via GET requests. You should consider removing or commenting them out if
  # you're using named routes and resources.
  # map.connect ':controller/:action/:id.:format'
  # map.connect ':controller/:action/:id'
end
