module Api
  module V1
    class BaseController < ApplicationController # keep logic seperate based on concerns nice n dry
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def record_not_found(error)
        render_error(error.message, :not_found)
      end
      
      def parameter_missing(error)
        render_error("Missing required parameters: #{error.param}", :bad_request)
      end

      def unprocessable_entity_response(exception)
        render_error(exception.record.errors.full_messages, :unprocessable_entity)
      end
      
      def render_error(message, status = 400)
        errors = message.is_a?(Array) ? message : [message]
        render json: {
          message: "Your request cannot be completed",
          errors: errors
        }, status: status
      end
      
      # def min_price_exceeds_max_price?
      #   params[:min_price].present? && params[:max_price].present? && 
      #     params[:min_price].to_f > params[:max_price].to_f
      # end

      def negative_price_params?
        (params[:min_price].present? && params[:min_price].to_f <= 0) || 
        (params[:max_price].present? && params[:max_price].to_f < 0)
      end
      
      def invalid_parameter_combinations?
        params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      end
      
      def all_params_blank?(param_keys)
        param_keys.all? { |key| params[key].blank? }
      end
    end
  end
end