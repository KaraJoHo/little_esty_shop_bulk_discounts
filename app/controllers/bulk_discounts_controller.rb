class BulkDiscountsController < ApplicationController 
  before_action :find_merchant

  def index 
    @upcoming_holidays = UpcomingHolidayInfo.new.next_3_holidays
  end

  def show 
    @discount = BulkDiscount.find(params[:id])
  end

  def new 
    @discount = BulkDiscount.new
  end

  def create 
    new_discount = @merchant.bulk_discounts.new(bulk_discount_params)
    if new_discount.save
      redirect_to merchant_bulk_discounts_path(@merchant)
    else 
      flash[:notice] = new_discount.errors.full_messages
      redirect_to new_merchant_bulk_discount_path(@merchant)
    end
  end

  def edit 
    @discount = BulkDiscount.find(params[:id])
  end

  def update 
    @discount = BulkDiscount.find(params[:id])
    
    if @discount.update(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, @discount)
    else 
      flash[:notice] = @discount.errors.full_messages
      redirect_to edit_merchant_bulk_discount_path(@merchant, @discount)
    end
  end

  def destroy 
    discount = BulkDiscount.find(params[:id])
    discount.destroy 
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  private 
  def bulk_discount_params 
    params.require(:bulk_discount).permit(:name, :percentage_discount, :threshold)
  end

  def find_merchant 
    @merchant = Merchant.find(params[:merchant_id])
  end

end