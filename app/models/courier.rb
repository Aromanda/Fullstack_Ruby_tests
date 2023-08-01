# app/models/courier.rb
class Courier < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :address
  belongs_to :courier_status
  has_many :orders

  # Validations
    validates :user_id, :address_id, :courier_status_id, :phone, presence: true
    validates :active, inclusion: { in: [true, false], message: "can't be blank" }
  end
