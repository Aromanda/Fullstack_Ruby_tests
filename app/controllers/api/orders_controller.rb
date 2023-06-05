module Api
  class OrdersController < ActionController::Base
    skip_before_action :verify_authenticity_token
    include ApiHelper

    # GET /api/orders
    def index
      # TODO
    end

    # POST /api/orders
    def create
      # TODO
    end

  end
end
