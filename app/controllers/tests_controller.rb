class TestsController < ApplicationController
    def index
        render json: { guest_id: cookies.signed[:guest_id] || cookies[:guest_id] }
    end
end
