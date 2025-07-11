class BusinessesController < ApplicationController
  before_action :set_business, only: %i[ show edit update destroy ]

  def index
    @businesses = Business.all
  end

  def show
    @products = @business.products
  end

  def new
    @business = Business.new
  end

  def edit
  end

  def create
    @business = Business.new(business_params)

    if @business.save
      redirect_to @business, notice: "Business was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @business.update(business_params)
      redirect_to @business, notice: "Business was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @business.destroy!

    redirect_to businesses_path, status: :see_other, notice: "Business was successfully destroyed."
  end

  def scrape_posts
    CallServiceJob.perform_later(TemporaryService)
  end

  private
    def set_business
      @business = Business.find(params.expect(:id))
    end

    def business_params
      params.expect(business: %i[ title description website_url business_type ])
    end
end
