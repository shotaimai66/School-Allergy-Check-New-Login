Rails.application.routes.draw do
  root 'static_pages#top'

  # システム管理者用画面
  devise_for :system_admins, controllers: {
    sessions:      'system_admins/sessions',
    passwords:     'system_admins/passwords',
  }
  devise_for :teachers, controllers: {
    sessions:      'teachers/sessions',
    passwords:     'teachers/passwords',
    registrations: 'teachers/registrations',
    # omniauth_callbacks: "teachers/omniauth_callbacks"
  }


  resources :system_admins, only: %i(index)
  namespace :system_admins do
    resources :schools do
      resources :teachers, param: :tcode, only: %i[show new create edit update]
    end
  end

  # 学校区分
  scope '/:school_url' do

    root to: 'static_pages#school_top', as: 'top'

    # 先生画面
    devise_for :teachers, controllers: {
      sessions:      'teachers/sessions',
      passwords:     'teachers/passwords',
      registrations: 'teachers/registrations',
      # omniauth_callbacks: "teachers/omniauth_callbacks"
    }

    resource :teachers, except: %i(show create edit update destroy) do
      get '/creator', to: 'teachers#creator'
      resources :students do
        namespace :alergy_checks do
          resources :creators, only: %i(edit update destroy)
        end
      end
      resource :students do
        namespace :alergy_checks do
          resource :creator, only: %i(new create)
        end
      end
      post 'create'
      get 'show', as: :show
      get 'edit_info'
      patch 'update_info'
      delete 'destroy', as: :destroy
    end
    resource :students do
      namespace :alergy_checks do
        resource :creator, only: %i(new create) do
          get '/students', to: 'creators#search_student'
        end
      end
    end

    resources :classrooms do
      collection do
        get 'edit_using_class'
        patch 'update_using_class'
      end
    end
  end


  # 下記山田さん既存のルート
  resources :students do
    collection { post :import }
  end

  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get  'comfirmation'
    end

    resources :attendances, only: [:edit, :update] do
     member do
       get 'lunch_check'
       patch 'update_lunch_check'
     end
     collection do
        get 'lunch_check_info'
        patch 'update_lunch_check_info'
     end #collection do end
    end #resouces do end
  end #user resouces do end
end
#draw do end
