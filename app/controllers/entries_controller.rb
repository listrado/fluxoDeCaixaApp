class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: %i[ show edit update destroy ]

  def index
    entries = current_user.entries.order(date: :asc, created_at: :asc)

    running = 0.to_d
    @rows = entries.map do |e|
      income  = e.kind == "income"  ? e.amount : 0.to_d
      expense = e.kind == "expense" ? e.amount : 0.to_d
      running += income - expense

      { entry: e, income: income, expense: expense, balance: running }
    end
  end

  def new
    # vem do popup: kind = "income" ou "expense"
    preset_kind = params[:kind].presence_in(%w[income expense]) || "income"
    preset_category = params[:category].presence
    preset_category ||= "Investimento" if params[:preset] == "investment"

    @entry = current_user.entries.new(
      date: Date.current,
      kind: preset_kind,
      category: preset_category
    )
  end

  def create
    @entry = current_user.entries.new(entry_params)

    # proteção extra: se por algum motivo não veio, fixa pelo param
    @entry.kind ||= params[:kind].presence_in(%w[income expense]) || "income"

    if @entry.save
      redirect_to entries_path, notice: "Lançamento criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Preferido para navegação pós-UPDATE
  def update
    if @entry.update(entry_params)
      redirect_to entries_path, status: :see_other  # 303 → próximo é GET
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy

    # Se vier de XHR/Fetch pedindo JSON, devolve 204 (sem body)
    if request.format.json? || request.headers['Accept'].to_s.include?('application/json')
      head :no_content
    else
      # Navegação normal do navegador → redireciona (303 é o ideal pós-DELETE)
      redirect_to entries_url, notice: "Lançamento removido.", status: :see_other
    end
  end

  private

  def set_entry
    @entry = current_user.entries.find(params[:id])
  end

  def entry_params
    # mantém :kind porque vamos passar escondido (hidden_field)
    params.require(:entry).permit(:date, :category, :description, :kind, :amount)
  end
end
