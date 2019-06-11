Rails.application.routes.draw do
  get 'videos/index'
  get 'videos/new'
  get 'videos/create'
  get    '/student_login',   to: 'sessions#new_student'
  post   '/student_login',   to: 'sessions#create_student'
  delete '/logout',  to: 'sessions#destroy'
  get    '/tutor_login',   to: 'sessions#new_tutor'
  post   '/tutor_login',   to: 'sessions#create_tutor'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  root 'static_pages#home'
  get '/tutor_signup',  to: 'tutors#new'
  post '/tutor_signup', to: 'tutors#create'
  get '/student_signup', to: 'students#new'
  post '/student_signup', to: 'students#create'
  resources :tutors do
    member do
      get :students, :courses
    end
  end
  resources :courses
  resources :students do
    member do
      get :courses
    end
  end
  resources :subscriptions,       only: [:create, :destroy]
  resources :videos, only: [:index, :new, :create, :destroy]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
