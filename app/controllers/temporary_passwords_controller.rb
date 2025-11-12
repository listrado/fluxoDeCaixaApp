class TemporaryPasswordsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_monk!

  def create
    tp, raw = TemporaryPassword.generate_by!(current_user)
    redirect_to entries_path, notice: "Senha temporária gerada: #{raw}"
  rescue => e
    redirect_to entries_path, alert: e.message
  end

  private

  def require_monk!
    unless current_user&.user_class == "monk"
      redirect_to entries_path, alert: "Ação não permitida."
    end
  end
end
