# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update index show destroy]
      resources :courses, only: %i[create update index show destroy]
      resources :talent_courses, only: %i[index update]
      resources :learning_paths, only: %i[create destroy index update]
      scope 'talents/:talent_id/courses/:course_id' do
        post '/', to: 'talent_courses#create'
        delete '/', to: 'talent_courses#destroy'
      end
    end
  end
end
