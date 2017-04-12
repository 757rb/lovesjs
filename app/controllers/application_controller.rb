class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def react
    render
  end

  def glimmer
    render
  end
end
