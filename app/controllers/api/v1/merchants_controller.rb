module Api
  module V1
    class MerchantsController < BaseController
      def index
        if params[:returned_items] == "true" || params[:status] == "returned"
          merchants = Merchant.with_returned_items
        elsif params[:sorted] == "age"
          merchants = Merchant.sorted_by_created_at
        elsif params[:count] == "true"
          merchants = Merchant.with_item_counts
          render json: MerchantSerializer.new(merchants, { params: { include_item_count: true } }) and return
        else
          # Default case - include coupon counts
          merchants = Merchant.with_coupon_counts.with_invoices_with_coupons_counts
        end
        
        # For all cases except :count, use the standard serializer
        render json: MerchantSerializer.new(merchants)
      end
      
      def show
        merchant = Merchant.find(params[:id])
        render json: MerchantSerializer.new(merchant)
      end

      def create
        merchant = Merchant.new(merchant_params)
        
        if merchant.save
          render json: MerchantSerializer.new(merchant), status: :created
        else
          render_error(merchant.errors.full_messages)
        end
      end

      def destroy
        merchant = Merchant.find(params[:id])
        merchant.destroy
        head :no_content
      end

      def update
        merchant = Merchant.update(params[:id], merchant_params)
        render json: MerchantSerializer.new(merchant)
      end

      private
      
      def merchant_params
        params.require(:merchant).permit(:name)
      end
    end
  end
end