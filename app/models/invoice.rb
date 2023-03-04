class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_revenue_with_discount 

    gather_invoice_rev = invoice_items.joins(:bulk_discounts)
    .where('invoice_items.invoice_id': self.id)
    .select('invoice_items.*, 
            min(CASE 
            WHEN invoice_items.quantity >= bulk_discounts.threshold 
            THEN (invoice_items.quantity*invoice_items.unit_price)*(1 - bulk_discounts.percentage_discount*.01)
            ELSE invoice_items.unit_price END) as discounted')
    .group('invoice_items.id')

    InvoiceItem.select('sum(discounted.discounted)')
               .from(gather_invoice_rev, :discounted)
               .pluck('sum(discounted.discounted)')
               .first

  end
end
