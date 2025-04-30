class CouponSerializer
  include JSONAPI::Serializer

  attributes :name, :code, :status, :discount_type, :discount_value, :merchant_id, :times_used
  belongs_to :merchant

  attribute :times_used do |object|
    object.invoices.count

  end
end