Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check

  get "products", to: "products#index"
  get "products/:id", to:"products#get_single_product"
  post "products", to: "products#create"
  patch "products/:id", to: "products#update"
  post "products/search", to:"products#search"
  
  #dynamic category
  post 'filter_rules', to: 'filter_rules#create'
  get'filter_rules', to: 'filter_rules#index'
  get 'category/:filter_slug', to: 'products#dynamic_category'
  
  #percolate query 
  post 'filter_rules/create_index', to: 'filter_rules#create_index'
  post 'filter_rules/import', to: 'filter_rules#import'
  get 'filter_rules/fetch_all', to: 'filter_rules#fetch_all_percolator_queries'
  get 'filter_rules/:id', to: 'filter_rules#get_suitable_query'
end
