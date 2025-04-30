Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Search Endpoints
      namespace :merchants do
        get "find", to: "search#show"
        get "find_all", to: "search#index"
      end

      namespace :items do
        get "find", to: "search#show"
        get "find_all", to: "search#index"
      end

      # Merchant and Item Endpoints
      resources :merchants, except: [:new, :edit] do
        resources :items, only: [:index], controller: 'merchant_items'
        resources :customers, only: [:index], controller: 'merchant_customers'
        resources :invoices, only: [:index], controller: 'merchant_invoices'
      
      # Added for coupons
      resources :coupons, except: [:new, :edit, :destroy] do
        member do
          patch :deactivate
          patch :activate
        end
      end
    end
      
      resources :items, except: [:new, :edit] do
        get "merchant", to: "item_merchants#show"
      end
    end
  end
end