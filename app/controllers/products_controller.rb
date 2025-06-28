class ProductsController < ApplicationController
  before_action :set_business
  before_action :set_product, only: %i[ edit update destroy ]

  def new
    @product = @business.products.new
  end

  def create
    @product = @business.products.new(product_params)

    render :new, status: :unprocessable_entity unless @product.save
  end

  def edit
  end

  def update
  end

  def destroy
    @product.destroy!
  end

  private
    def product_params
      params.expect(product: %i[ title description ])
    end

    def set_business
      @business = Business.find(params[:business_id])
    end

    def set_product
      @product = @business.products.find(params[:id])
    end
end
