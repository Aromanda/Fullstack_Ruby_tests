module Api
  class OrdersController < ActionController::Base
    skip_before_action :verify_authenticity_token

    # GET /api/orders
    def index
      type = params[:type]
      id = params[:id]

      unless type && id
        return render json: { error: "Both 'user type' and 'id' parameters are required" }, status: :bad_request
      end

      unless %w[customer restaurant courier].include?(type)
        return render json: { error: "Invalid user type" }, status: :unprocessable_entity
      end

      orders = Order.user_orders(type, id)

      if orders.empty?
        return render json: [], status: :ok
      end

      render json: orders.map { |order| format_order(order) }, status: :ok
    end

    # POST /api/orders
    def create
      restaurant_id = params[:restaurant_id]
      customer_id = params[:customer_id]
      products = params[:products]

      if restaurant_id.present? && customer_id.present? && products.present?
        restaurant = Restaurant.find_by(id: restaurant_id)
        customer = Customer.find_by(id: customer_id)

        if restaurant && customer
          order = Order.new(
            restaurant: restaurant,
            customer: customer,
            order_status: OrderStatus.find_by(name: "pending")
          )

          products.each do |product_data|
            product = Product.find_by(id: product_data[:id])
            if product
              order.save  # Save the order first
              order.product_orders.create(
                product: product,
                product_quantity: product_data[:quantity],
                product_unit_cost: product.cost
              )
            else
              render json: { error: "Invalid product ID" }, status: :unprocessable_entity
              return
            end
          end

          if order.save
            response_body = {
              restaurant_id: order.restaurant_id,
              customer_id: order.customer_id,
              products: products
            }

            render json: response_body, status: :created
          else
            render json: { error: order.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        else
          render json: { error: "Invalid restaurant or customer ID" }, status: :unprocessable_entity
        end
      else
        render json: { error: "Restaurant ID, customer ID, and products are required" }, status: :bad_request
      end
    end

    # POST /api/orders/:id/status
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

    private

    def format_order(order)
      {
        id: order.id,
        customer_id: order.customer.id,
        customer_name: order.customer.user&.name, # Assuming a 'user' association with 'name'
        customer_address: order.customer.address,
        restaurant_id: order.restaurant.id,
        restaurant_name: order.restaurant.name, # Adjust based on your actual schema
        restaurant_address: order.restaurant.address,
        courier_id: order.courier&.id,
        courier_name: order.courier&.user&.name, # Assuming a 'user' association with 'name'
        status: order.order_status.name,
        products: order.product_orders.map do |product_order|
          {
            product_id: product_order.product_id,
            product_name: product_order.product.name,
            quantity: product_order.product_quantity,
            unit_cost: product_order.product_unit_cost,
            total_cost: product_order.product_unit_cost * product_order.product_quantity
          }
        end,
        total_cost: order.total_cost # Define this method in Order model if needed
      }
    end

    def render_422_error(message)
      render json: { error: message }, status: :unprocessable_entity
    end
  end
end 