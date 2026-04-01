Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check
  get "products", to: "products#index"
  post "products", to: "products#create"
  post "products/add_all", to: "products#adding"
  patch "products/:id", to: "products#update"
  # delete "products/:id", to: "products#deleting"
  get "products/add_all", to:"products#add_all"
  post "products/search", to:"products#search"
 
end
