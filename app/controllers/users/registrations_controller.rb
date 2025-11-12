# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: %i[new create]
  before_action :require_valid_invite!, only: [:new, :create]

  def create
    # Já temos invite garantido pelo before_action
    tp = TemporaryPassword.find_by(password: session[:invite_password])
    return redirect_to new_signup_gate_path, alert: "Código inválido." if tp.nil?
    return redirect_to new_signup_gate_path, alert: "Este código já foi usado." if tp.used?

    build_resource(sign_up_params)
    resource.user_class ||= "villager"  # default
    if resource.save
      # marca o código como usado só depois do usuário criado
      tp.mark_as_used!(resource.email)
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource, status: :unprocessable_entity
    end
  end

  private

  def require_valid_invite!
    code = session[:invite_password].to_s.strip.upcase
    if code.blank?
      redirect_to new_signup_gate_path, alert: "Valide o código antes de cadastrar."
      return
    end

    tp = TemporaryPassword.find_by(password: code)
    if tp.nil?
      session.delete(:invite_password)
      redirect_to new_signup_gate_path, alert: "Código inválido."
    elsif tp.used?
      session.delete(:invite_password)
      quando = tp.used_at ? I18n.l(tp.used_at, format: :short) : "anteriormente"
      redirect_to new_signup_gate_path, alert: "Este código já foi usado (#{quando})."
    end
  end
end