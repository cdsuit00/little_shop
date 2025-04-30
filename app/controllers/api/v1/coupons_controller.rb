module Api
  module V1
    class CouponsController < BaseController
      before_action :set_merchant
      before_action :set_coupon, only: [:show, :update, :activate, :deactivate]

      def index
        coupons = @merchant.coupons
        render json: CouponSerializer.new(coupons)
      end

      def show
        render json: CouponSerializer.new(@coupon)
      end

      def create
        coupon = @merchant.coupons.new(coupon_params)

        if @merchant.active_coupons.count >= 5 && coupon_params[:status] == 'active'
          render_error(["Maximum of 5 active coupons reached"], :unprocessable_entity)
        elsif coupon.save
          render json: CouponSerializer.new(coupon), status: :created
        else
          render_error(["Name can't be blank"], :unprocessable_entity)
        end
      end

      def update
        if @merchant.active_coupons.count >= 5 && coupon_params[:status] == 'active' && @coupon.inactive?
          render_error(["Maximum of 5 active coupons reached"], :unprocessable_entity)
        elsif @coupon.update(coupon_params)
          render json: CouponSerializer.new(@coupon)
        else
          render_error(@coupon.errors.full_messages)
        end
      end

      def activate
        if @merchant.active_coupons.count >= 5
          render_error(["Maximum of 5 active coupons reached"], :unprocessable_entity)
        else
          @coupon.activate!
          render json: CouponSerializer.new(@coupon)
        end
      end

      def deactivate
        @coupon.deactivate!
        render json: CouponSerializer.new(@coupon)
      end

      private

      def set_merchant
        @merchant = Merchant.find(params[:merchant_id])
      end

      def set_coupon
        @coupon = @merchant.coupons.find(params[:id])
      end

      def coupon_params
        params.require(:coupon).permit(:name, :code, :status, :discount_type, :discount_value)
      end
    end
  end
end