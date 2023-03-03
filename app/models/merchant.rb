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
    #first condition - when the item quantity is equal to or over the threshold
    #second condition - when the quantity is less than the threshold 
    #only apply the discount to the item that is over the quantity(charge other item(s) with regular unit price)
    #use invoice items table(has specific item id)
    #look at the merchants invoice items for the specific invoice(where invoice id = invoice.id)
    #find specific condition of item quantity
    #perform that calculation and put it in  a new column
    #sum the column from the new table
    # *ALSO: Merchants can have multiple bulk discounts
          #If an item meets the quantity threshold for multiple bulk discounts, only the one with the greatest percentage discount should be applied*


    #cover conditions ..can make a couple tables and use an if statement
   
    
      if invoice_items.joins(:bulk_discounts).where(invoice_id: invoice.id).where('invoice_items.quantity >= bulk_discounts.threshold').count > 0 

        invoice_items.joins(:bulk_discounts)
                     .where(invoice_id: invoice.id)
                     .sum('(invoice_items.unit_price * invoice_items.quantity) * (1 - bulk_discounts.percentage_discount*.01)') 

      elsif invoice_items.joins(:bulk_discounts).where(invoice_id: invoice.id).where('invoice_items.quantity <= bulk_discounts.threshold')

        invoice_items.joins(:bulk_discounts)
                     .where(invoice_id: invoice.id)
                     .sum('(invoice_items.unit_price * invoice_items.quantity)')
      end

     #try a case when to use in one table
    
    # cases = "CASE 
    #         WHEN invoice_items.quantity >= bulk_discounts.threshold 
    #         THEN (invoice_items.unit_price * invoice_items.quantity) * (1 - bulk_discounts.percentage_discount*.01)
    #         ELSE invoice_items.unit_price
    #         END"

    #   gather_revenue = invoice_items
                  #     .joins(:bulk_discounts)
                  #     .where(invoice_id: invoice.id)
                  #     .select("invoice_items.*, sum(#{cases}) as discounted")
                  #     .group('invoice_items.id')



    #  gather_revenue.sum("discounted")

     #discounted column does not exist??
     #cant refer to a column in the where clause, can use selects to order by
     #discounted has not been evaluated so use another from to get the result of discounted

     #select the sum of the discount from this gather table

    # invoice_items.select('sum(discounted.discounted)').from(gather_revenue, :discounted).pluck('sum(discounted.discounted)').first

    #missing from clause entry for table invoice_items...? 
    #  ELSE invoice_items.unit_price
    # END) as discounted FROM "invoice_items" INNER JOIN "items" "items_invoice_items_join" ON 
    #inner join items on nothing...?

    #AR guides shows from using the whole table (instead of the specific invoice items of the merchant)


    # InvoiceItem.select('sum(discounted.discounted)').from(gather_revenue, :discounted).pluck('sum(discounted.discounted)').first


  #first solution for first condition(item qualifies for discount), saving for reference 
    #  invoice_items.joins(:bulk_discounts)
    #  .where('invoice_items.quantity >= bulk_discounts.threshold')
    #  .where(invoice_id: invoice.id)
    #  .distinct
    #  .sum('(invoice_items.unit_price * invoice_items.quantity) * (1 - bulk_discounts.percentage_discount*.01)')
  end
end
