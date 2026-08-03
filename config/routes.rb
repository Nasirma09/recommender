Rails.application.routes.draw do
    resources :buttons
    root "homepage#index"
end
