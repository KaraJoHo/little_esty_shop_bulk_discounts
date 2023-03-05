class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_many :bulk_discounts, through: :item

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def apply_discount 
    bulk_discounts.joins(:invoice_items) 
                   .where('invoice_items.id': self.id) 
                   .where('invoice_items.quantity >= bulk_discounts.threshold')
                   .order(percentage_discount: :desc) 
                   .first
  end
end
