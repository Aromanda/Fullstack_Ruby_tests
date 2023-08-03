module Api
  class OrdersController < ActionController::Base
    skip_before_action :verify_authenticity_token
    include ApiHelper

    # GET /api/orders
    def index
      type = params[:type]
      id = params[:id]

      unless type && id
        return render json: { error: "Both 'user type' and 'id' parameters are required" }, status: :bad_request
      end

      if type != 'customer' && type != 'restaurant' && type != 'courier'
        return render json: { error: "Invalid user type" }, status: :unprocessable_entity
      end

      orders = Order.user_orders(type, id)

      if orders.empty?
        return render json: [], status: :ok
      end

      render json: orders.as_json(include: { customer: { only: [:id, :name, :address] },
                                             restaurant: { only: [:id, :name, :address] },
                                             courier: { only: [:id, :name] },
                                             order_status: { only: [:id, :name] },
                                             product_orders: { only: [:id, :product_id, :product_quantity, :product_unit_cost] } },
                                  methods: :total_cost), status: :ok
    end

    # POST /api/orders
    def create
      # Extract the parameters from the request
      restaurant_id = params[:restaurant_id]
      customer_id = params[:customer_id]
      products = params[:products]

      # Check if all required parameters are present
      if restaurant_id.present? && customer_id.present? && products.present?
        # Find the Restaurant and Customer
        restaurant = Restaurant.find_by(id: restaurant_id)
        customer = Customer.find_by(id: customer_id)

        # Check if valid Restaurant and Customer are found
        if restaurant && customer
          # Create a new Order with the provided data
          order = Order.new(
            restaurant: restaurant,
            customer: customer,
            order_status: OrderStatus.find_by(name: "pending")
          )

          # Create ProductOrders for each product in the request
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
          

          # Save the Order and ProductOrders
          if order.save
            render json: order, status: :created
          else
            render json: { error: order.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        else
          render json: { error: "Invalid restaurant or customer ID" }, status: :unprocessable_entity
        end
      else
        render json: { error: "Restaurant ID, customer ID, and products are required" }, status: :bad_request
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
end
