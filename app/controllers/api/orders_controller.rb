module Api
  class OrdersController < ActionController::Base
    skip_before_action :verify_authenticity_token
    include ApiHelper

    # GET /api/orders
    def index
      # Fetch all orders from the database
      @orders = Order.all

      # Return the list of orders as JSON
      render json: @orders
    end

    # POST /api/order/:id/status
    def set_status
      @order = Order.find(params[:id])
      new_status_name = params[:status]

      # Find the OrderStatus record with the given name
      new_status = OrderStatus.find_by(name: new_status_name)

      unless new_status
        # If the status name is invalid, return a 422 status code with an error message
        render json: { error: "Invalid status name" }, status: :unprocessable_entity
        return
      end

      # Update the order status
      @order.order_status = new_status

      if @order.save
        # If the order status is successfully updated, return the updated order as JSON with a status code of 200 (OK)
        render json: @order
      else
        # If there are any validation errors or issues with updating the order status, return the errors as JSON with a status code of 422 (unprocessable entity).
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
