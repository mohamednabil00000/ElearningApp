# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update index show destroy]
      resources :courses, only: %i[create update index show destroy]
      resources :talent_courses, only: %i[index update]
      resources :learning_paths, only: %i[create destroy index update]
      resources :talent_learning_paths, only: %i[show]
      scope 'talents/:talent_id' do
        scope 'courses/:course_id' do
          post '/', to: 'talent_courses#create'
          delete '/', to: 'talent_courses#destroy'
        end
        scope 'learning_paths/:learning_path_id' do
          post '/', to: 'talent_learning_paths#create'
          delete '/', to: 'talent_learning_paths#destroy'
        end
      end
    end
  end
end
