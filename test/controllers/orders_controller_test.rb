require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(name: "Tester", email: "test@test.com", password: "password")
    @address = Address.create(street_address: "addr1", city: "city1", postal_code: "zip1")
    @restaurant = Restaurant.create(user_id: @user.id, address_id: @address.id, phone: "234858", name: "Burger Fang")
    @customer = Customer.create(user_id: @user.id, address_id: @address.id, phone: "123123456")
    @order_status = OrderStatus.create(name: "delivered")
    @order = Order.create(restaurant_id: @restaurant.id, customer_id: @customer.id, order_status_id: @order_status.id)
  end

  test "table has required columns" do
    required_columns = %w[restaurant_id customer_id courier_id order_status_id restaurant_rating]
    required_columns.each do |column|
      assert_includes Order.column_names, column, "Column '#{column}' not found"
    end
  end

  test "columns have required data type" do
    required_columns = {
      restaurant_id: :integer,
      customer_id: :integer,
      courier_id: :integer,
      order_status_id: :integer,
      restaurant_rating: :integer,
    }

    required_columns.each do |column, data_type|
      assert_equal data_type, Order.column_for_attribute(column).type, "Wrong data type for #{column} column"
    end
  end

  test "presence validation" do
    required_attributes = {
      restaurant_id: "Restaurant",
      customer_id: "Customer",
      order_status_id: "Order status",
    }

    required_attributes.each do |attribute, message|
      order = Order.new({ restaurant_id: @restaurant.id, customer_id: @customer.id, order_status_id: @order_status.id })
      order[attribute] = ""
      assert_not order.valid?, "#{attribute} should not be empty"
      assert_includes order.errors.full_messages, "#{message} can't be blank"
    end
  end

  test "order can have 0..* product orders" do
    assert_respond_to Order.new, :product_orders, "Order should have 0..* product orders"
  end

  test "restaurant rating range" do
    order = Order.create(restaurant_id: @restaurant.id, customer_id: @customer.id, order_status_id: @order_status.id, restaurant_rating: 0)
    assert_not order.valid?, "Restaurant rating should be comprised between 1 and 5 inclusively"
  end

  test "update order status to 'pending'" do
    post api_order_status_path(@order.id), params: { status: "pending" }
    assert_response :success
    assert_equal "pending", @order.reload.order_status.name
  end

  test "update order status to 'in progress'" do
    post api_order_status_path(@order.id), params: { status: "in progress" }
    assert_response :success
    assert_equal "in progress", @order.reload.order_status.name
  end

  test "update order status to 'delivered'" do
    post api_order_status_path(@order.id), params: { status: "delivered" }
    assert_response :success
    assert_equal "delivered", @order.reload.order_status.name
  end

  test "return 422 error for invalid status" do
    post api_order_status_path(@order.id), params: { status: "invalid" }
    assert_response 422
  end

  test "return 422 error for invalid order" do
    post api_order_status_path(0), params: { status: "pending" }
    assert_response 422
  end
end