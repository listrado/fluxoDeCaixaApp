class Entry < ApplicationRecord
  belongs_to :user
  enum :kind, { income: 0, expense: 1 }
  validates :date, :category, :kind, :amount, presence: true
  validates :amount, numericality: { greater_than: 0, less_than: 10_000_000_000 }
  def signed_amount
    income? ? amount : -amount
  end
end
