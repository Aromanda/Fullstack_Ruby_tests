module Api
  class OrdersController < ActionController::Base
    skip_before_action :verify_authenticity_token
    include ApiHelper

    # GET /api/orders
    def index
      user_type = params[:type]
      user_id = params[:id]

      if user_type && user_id
        valid_user_types = ["customer", "restaurant", "courier"]
        if valid_user_types.include?(user_type)
          @orders = Order.where("#{user_type}_id": user_id)
          render json: @orders
        else
          render json: { error: "Invalid user type" }, status: :unprocessable_entity
        end
      else
        render json: { error: "Both 'user type' and 'id' parameters are required" }, status: :bad_request
      end
    end

    # POST /api/order/:id/status
    def set_status
      status = params[:status]
      id = params[:id]

      unless status.present? && status.in?(["pending", "in progress", "delivered"])
        return render_422_error("Invalid status")
      end

      order = Order.find_by(id: id)
      unless order
        return render_422_error("Invalid order")
      end

      order.update(order_status_id: OrderStatus.find_by(name: status)&.id)
      render json: { status: order.order_status.name }, status: :ok
    end
  end
end
