class LeadsController < ApplicationController
  before_action :set_business

  def show
    @products = @business.products
    @leads = LeadFindingAgent.new.fetch_leads(@business)
  end

  private
    def set_business
      @business = Business.find(params[:business_id])
    end
end
