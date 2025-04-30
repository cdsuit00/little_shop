class InvoiceSerializer
    include JSONAPI::Serializer
  attributes :id, :status, :created_at, :updated_at, :customer_id, :merchant_id

  attribute :coupon_id, if: Proc.new { |invoice| invoice.coupon_id.present? }

end