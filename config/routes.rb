Rails.application.routes.draw do
  get "recommender_query/index"
  get "recommender_query/find_product_recommendations" => "recommender_query#find_product_recommendations", as: :find_recommendation
    resources :uploaders
    root "homepage#index"

end
