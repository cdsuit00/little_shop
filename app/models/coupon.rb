class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  enum status: { inactive: 0, active: 1 }
  enum discount_type: { percent_off: 0, dollar_off: 1 }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_value, numericality: { greater_than: 0 }
  validate :active_coupon_limit, on: :update

  def activate!
    update!(status: 'active')
  end

  def deactivate!
    update!(status: 'inactive')
  end

  private

  def active_coupon_limit
    if status_changed?(to: 'active') && merchant.active_coupons.count >= 5
      errors.add(:status, "Merchant can only have 5 active coupons at a time")
    end
  end
end