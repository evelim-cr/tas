class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # Pagina 404
  config.action_dispatch.rescue_responses.merge!(
    'MyCustomException' => :not_found
  )
end
