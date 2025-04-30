module Api
  module V1
    class MerchantInvoicesController < BaseController
      def index
        merchant = Merchant.find(params[:merchant_id])
        
        invoices = if params[:status].present?
                    merchant.invoices.includes(:coupon).where(status: params[:status])
                  else
                    merchant.invoices.includes(:coupon)
                  end
        
        render json: InvoiceSerializer.new(invoices)
      end
    end
  end
end