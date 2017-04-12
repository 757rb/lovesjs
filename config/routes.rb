Rails.application.routes.draw do
  get 'react', to: 'application#react'
  get 'glimmer', to: 'application#glimmer'
end
