class TemporaryPassword < ApplicationRecord
  # Escopos
  scope :available, -> { where(used: false) }

  # Validações
  validates :password, presence: true, uniqueness: { case_sensitive: false }

  # Normaliza antes de validar
  before_validation :normalize!

  # (opcional) trava criação por "monk"
  belongs_to :creator, class_name: "User", optional: true
  validate :creator_must_be_monk, on: :create

  def creator_must_be_monk
    if creator.present? && creator.user_class != "monk"
      errors.add(:creator, "must be a monk")
    end
  end

  def self.generate_by!(user)
    raise "Not authorized" unless user&.user_class == "monk"
    raw = SecureRandom.urlsafe_base64(8).upcase
    tp = create!(password: raw, creator: user)
    [tp, raw]
  end

  def mark_as_used!(email = nil)
    update!(used: true, used_at: Time.current, email: email)
  end

  private

  def normalize!
    self.password = password.to_s.strip.upcase
  end
end
