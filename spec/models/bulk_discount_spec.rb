require 'rails_helper'

RSpec.describe BulkDiscount do 
  describe 'relationships' do 
    it {should belong_to(:merchant)}
    it {should have_many(:items).through(:merchant)}
    it {should have_many(:invoice_items).through(:items)}
  end

  describe 'validations' do 
    it {should validate_numericality_of(:percentage_discount).is_greater_than(0)}
    it {should validate_numericality_of(:percentage_discount).is_less_than(100)}
    it {should validate_numericality_of(:threshold)}
    it {should validate_presence_of(:name)}
  end
end