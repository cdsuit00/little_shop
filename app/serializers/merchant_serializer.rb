class MerchantSerializer
  include JSONAPI::Serializer
  
  attributes :name

  attribute :coupons_count do |merchant|
    merchant.respond_to?(:coupons_count) ? merchant.coupons_count : merchant.coupons.count
  end

  attribute :invoices_with_coupons_count do |merchant|
    if merchant.respond_to?(:invoices_with_coupons_count)
      merchant.invoices_with_coupons_count
    else
      merchant.invoices.where.not(coupon_id: nil).count
    end
  end

  attribute :item_count, if: Proc.new { |_,params| params && params[:include_item_count] } do |merchant|
    merchant.respond_to?(:item_count) ? merchant.item_count : merchant.items.count
  end
end