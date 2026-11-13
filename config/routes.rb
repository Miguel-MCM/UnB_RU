Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "cadastro", to: "users#new", as: :signup
  post "cadastro", to: "users#create"
  get "login", to: "sessions#new"

  get "/cardapio_atual", to: "menus#current", as: :current_menu

  resources :access_reports, path: "relatorio_acessos", only: [ :index ] do
    collection do
      get :export_pdf
    end
  end

  resources :statements, path: "extrato", only: [ :index ] do
    collection do
      get :export_pdf
    end
  end
end
