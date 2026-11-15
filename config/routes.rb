Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "cadastro", to: "users#new", as: :signup
  post "cadastro", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resource :recarga, only: %i[show create]
  resource :fastpass, only: :show, controller: "fastpass"
  resources :inscricoes_fastpass, only: :create, path: "fastpass/inscricoes"
  resources :notificacoes, only: :index

  namespace :operador do
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    resource :ponto_de_acesso, only: %i[show update], controller: "pontos_de_acesso"
    resource :terminal, only: :show, controller: "terminal"
    resource :historico, only: :show, controller: "historicos"
    resources :acessos, only: :create do
      resource :passagem, only: :create, controller: "passagens"
    end
  end

  namespace :admin do
    resources :restaurantes, except: :show do
      resources :catracas, only: :create
      resources :turnos, only: %i[index create]
    end
    resources :catracas, only: %i[edit update destroy]
    resources :turnos, only: [] do
      resources :time_frames, only: :create
    end
  end

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
