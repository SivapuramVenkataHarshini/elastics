Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check
  get "products", to: "products#index"
  post "products", to: "products#create"
  patch "products/:id", to: "products#update"
  post "products/search", to:"products#search"
  post 'filter_rules', to: 'filter_rules#create'
  get'filter_rules', to: 'filter_rules#index'
  get 'category/:filter_slug', to: 'products#dynamic_category'
end
