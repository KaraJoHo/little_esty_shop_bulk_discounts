class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts

  enum status: [:enabled, :disabled]

  def favorite_customers
    transactions.joins(invoice: :customer)
                .where('result = ?', 1)
                .where("invoices.status = ?", 2)
                .select("customers.*, count('transactions.result') as top_result")
                .group('customers.id')
                .order(top_result: :desc)
                .distinct
                .limit(5)
  end

  def ordered_items_to_ship
    item_ids = InvoiceItem.where("status = 0 OR status = 1").order(:created_at).pluck(:item_id)
    item_ids.map do |id|
      Item.find(id)
    end
  end

  def top_5_items
     items
     .joins(invoices: :transactions)
     .where('transactions.result = 1')
     .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
     .group(:id)
     .order('total_revenue desc')
     .limit(5)
   end

  def self.top_merchants
    joins(invoices: [:invoice_items, :transactions])
    .where('result = ?', 1)
    .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
    .group(:id)
    .order('total_revenue DESC')
    .limit(5)
  end

  def best_day
    invoices.where("invoices.status = 2")
            .joins(:invoice_items)
            .select('invoices.created_at, sum(invoice_items.unit_price * invoice_items.quantity) as revenue')
            .group("invoices.created_at")
            .order("revenue desc", "invoices.created_at desc")
            .first&.created_at&.to_date
  end

  def total_revenue_without_discounts(invoice)
    invoice_items.where(invoice_id: invoice.id).distinct.sum('invoice_items.unit_price*invoice_items.quantity')
  end

  def total_discounted_revenue(invoice)
      # if invoice_items.joins(:bulk_discounts).where(invoice_id: invoice.id).where('invoice_items.quantity >= bulk_discounts.threshold').count > 0 

      #   invoice_items.joins(:bulk_discounts)
      #                .where(invoice_id: invoice.id)
      #                .sum('(invoice_items.unit_price * invoice_items.quantity) * (1 - bulk_discounts.percentage_discount*.01)') 

      # elsif invoice_items.joins(:bulk_discounts).where(invoice_id: invoice.id).where('invoice_items.quantity <= bulk_discounts.threshold')

      #   invoice_items.joins(:bulk_discounts)
      #                .where(invoice_id: invoice.id)
      #                .sum('(invoice_items.unit_price * invoice_items.quantity)')
      # end

    gather_revenue = invoice_items
                     .joins(:bulk_discounts)
                     .where(invoice_id: invoice.id)
                     .select("invoice_items.*, 
                                    min(CASE 
                                    WHEN invoice_items.quantity >= bulk_discounts.threshold 
                                    THEN (invoice_items.unit_price * invoice_items.quantity) * (1 - bulk_discounts.percentage_discount*.01)
                                    ELSE invoice_items.unit_price * invoice_items.quantity
                                    END) as discounted")
                     .group('invoice_items.id')                  
    InvoiceItem.select(Arel.sql('sum(discounted.discounted)'))
               .from(gather_revenue, :discounted)
               .pluck(Arel.sql('sum(discounted.discounted)'))
               .first                             
  end
end
