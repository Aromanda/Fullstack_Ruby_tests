require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: 'test@test.com', password: 'good_password', name: "user 1")
    @address = Address.create!(street_address: "Street 1", city: "City 1", postal_code: "11111")
    @restaurant = Restaurant.create!(user: @user, address: @address, name: "Restaurant 1", phone: "123456", price_range: 2)
    @customer = Customer.create!(user: @user, address: @address, phone: "123456")
    @product = Product.create!(name: "Product 1", cost: 10, restaurant: @restaurant)
    @order_status = OrderStatus.create(name: "pending")
    OrderStatus.create(name: "in progress")
    OrderStatus.create(name: "delivered")
    @order = Order.create!(restaurant: @restaurant, customer: @customer, order_status: @order_status, restaurant_rating: 4)
  end

  test "GET /api/orders returns 200 with valid parameters" do
    get '/api/orders', params: { type: 'customer', id: @customer.id }
    assert_response :ok
    # You can add additional assertions for the response body as described earlier.
  end

  test "GET /api/orders returns 422 with invalid user type" do
    get '/api/orders', params: { type: 'invalid_type', id: @customer.id }
    assert_response :unprocessable_entity
    assert_equal '{"error":"Invalid user type"}', response.body
  end

  test "GET /api/orders returns 200 with id not found" do
    get '/api/orders', params: { type: 'customer', id: 9999 }
    assert_response :ok
    assert_equal '[]', response.body
  end

  test "GET /api/orders returns 400 when user type and id parameters are missing" do
    get '/api/orders'
    assert_response :bad_request
    assert_equal '{"error":"Both \'user type\' and \'id\' parameters are required"}', response.body
  end

  test "update order status to 'pending'" do
    post "/api/orders/#{@order.id}/status", params: { status: "pending" }
    assert_response :success
    assert_equal({ "status" => "pending" }, JSON.parse(response.body))
    assert_equal "pending", @order.reload.order_status.name
  end

  test "create order with invalid product" do
    post "/api/orders", params: {
      restaurant_id: @restaurant.id,
      customer_id: @customer.id,
      products: [{ id: 999, quantity: 2 }]
    }
    assert_response :unprocessable_entity
    assert_equal '{"error":"Invalid product ID"}', response.body
  end

  test "update order status to 'in progress'" do
    post "/api/orders/#{@order.id}/status", params: { status: "in progress" }
    assert_response :success
    assert_equal "in progress", @order.reload.order_status.name
  end

  test "update order status to 'delivered'" do
    post "/api/orders/#{@order.id}/status", params: { status: "delivered" }
    assert_response :success
    assert_equal "delivered", @order.reload.order_status.name
  end

  test "return 422 error for invalid status" do
    post "/api/orders/#{@order.id}/status", params: { status: "invalid" }
    assert_response 422
  end

  test "return 422 error for invalid order" do
    post "/api/orders/0/status", params: { status: "pending" }
    assert_response 422
  end
end