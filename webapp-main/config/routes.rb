Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'kafka/testsend'
  get 'kafka/testget'
  get 'twitter/testsearch'
  get 'db/test'

  get '/search', to: 'search#search'
  get '/result', to: 'search#result'
  get '/showresult', to: 'search#show_result'

  root 'search#index'
end
