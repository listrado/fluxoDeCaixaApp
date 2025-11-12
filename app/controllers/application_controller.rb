class ApplicationController < ActionController::Base
  # Exige login em tudo, EXCETO telas do Devise e o signup_gate
  before_action :authenticate_user!, unless: :devise_or_signup_gate?

  private

  def devise_or_signup_gate?
    devise_controller? || params[:controller] == 'signup_gate'
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
