class BulkDiscount < ApplicationRecord 
  belongs_to :merchant 
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items 
  validates_presence_of :name
  validates_numericality_of :threshold 
  validates_numericality_of :percentage_discount, greater_than: 0, less_than: 100
end