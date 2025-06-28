class LeadsController < ApplicationController
  before_action :set_business

  def show
    @products = @business.products
    @business_leads, @products_leads = LeadService.call(products: @products, business: @business)
  end

  private
    def set_business
      @business = Business.find(params[:business_id])
    end
end
