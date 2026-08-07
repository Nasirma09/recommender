Rails.application.routes.draw do
  namespace :api do
    get "recommendations", to: "recommendations#index"
  end
  get "recommender_query" => 'recommender_query#index'
  get "recommender_query/find_product_recommendations" => "recommender_query#find_product_recommendations", as: :find_recommendation
  resources :uploaders
  root "homepage#index"
end
