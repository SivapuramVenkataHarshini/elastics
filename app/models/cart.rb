class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  enum :status, {
    active: 0,
    checked_out: 1,
    abandoned: 2
  }
end