Rails.application.routes.draw do
  get '/packages', to: 'packages#list'
end
