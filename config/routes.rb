Myapp::Application.routes.draw do
  resources :comments


  resources :tags

  match "/build" => 'routines#new'
  match "/cal" => 'routines#cal'
  match "/build_routine" => 'routines#build_routine'
  match "/filtered" => 'routines#filtered'
  resources :routines


  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end
