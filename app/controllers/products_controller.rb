class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    @product_latest = @product.first
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(title: "...", body: "...")

    if @product.save
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end
end
