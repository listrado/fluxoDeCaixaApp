class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: %i[ show edit update destroy ]

  def index
    scope = current_user.entries.order(:date, :id)

    @running_balance = 0.to_d
    @rows = scope.map do |e|
      income  = (e.respond_to?(:income?)  && e.income?)  ? e.amount.to_d : 0.to_d
      expense = (e.respond_to?(:expense?) && e.expense?) ? e.amount.to_d : 0.to_d
      @running_balance += (income - expense)
      { entry: e, income: income, expense: expense, balance: @running_balance }
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

  def update
    if @entry.update(entry_params)
      redirect_to entries_path, notice: "Lançamento atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to entries_url, notice: "Lançamento removido."
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
