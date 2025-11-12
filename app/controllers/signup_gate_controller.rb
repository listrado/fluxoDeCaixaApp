class SignupGateController < ApplicationController
  # garante que o gate fica acessível sem login, mesmo que mude algo no ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  # Tela do código
  def new
  end

  # Recebe o código, valida e guarda em sessão
  def create
    code = params[:invite].to_s.strip.upcase
    tp   = TemporaryPassword.find_by(password: code)

    if tp.nil?
      redirect_to new_signup_gate_path, alert: "Código inválido."
    elsif tp.used?
      quando = tp.used_at ? I18n.l(tp.used_at, format: :short) : "anteriormente"
      redirect_to new_signup_gate_path, alert: "Este código já foi usado (#{quando})."
    else
      session[:invite_password] = tp.password
      redirect_to new_user_registration_path, notice: "Código validado. Preencha seu cadastro."
    end
  end
end
