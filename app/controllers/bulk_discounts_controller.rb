class BulkDiscountsController < ApplicationController 

  def index 
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show 
    @discount = BulkDiscount.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def new 
    @discount = BulkDiscount.new
  end

  def create 
    @merchant = Merchant.find(params[:merchant_id])
    new_discount = @merchant.bulk_discounts.new(bulk_discount_params)
    if new_discount.save
      redirect_to merchant_bulk_discounts_path(@merchant)
    else 
      flash[:notice] = new_discount.errors.full_messages
      redirect_to new_merchant_bulk_discount_path(@merchant)
    end
  end

  def edit 
    @merchant = Merchant.find(params[:merchant_id]) 
    @discount = BulkDiscount.find(params[:id])
  end

  def update 
    @merchant = Merchant.find(params[:merchant_id]) 
    @discount = BulkDiscount.find(params[:id])
    
    @discount.update!(bulk_discount_params)
    if @discount.update(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, @discount)
    else 
      flash[:notice] = @discount.errors.full_messages
      # render :edit, status: :unprocessable_entity
      redirect_to edit_merchant_bulk_discount_path(@merchant, @discount)
    end

  end

  def destroy 
    merchant = Merchant.find(params[:merchant_id]) 
    discount = BulkDiscount.find(params[:id])
    discount.destroy 
    redirect_to merchant_bulk_discounts_path(merchant)
  end

  private 
  def bulk_discount_params 
    params.require(:bulk_discount).permit(:name, :percentage_discount, :threshold)
  end

  def find_merchant 
    @merchant = Merchant.find(params[:merchant_id])
  end

end