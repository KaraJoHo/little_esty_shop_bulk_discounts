require 'rails_helper'

RSpec.describe 'merchant bulk discounts index' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @merchant2 = Merchant.create!(name: 'Dog Care')

    @discount1 = BulkDiscount.create!(name: "Discount 1", percentage_discount: 20, threshold: 5, merchant_id: @merchant1.id)
    @discount2 = BulkDiscount.create!(name: "Discount 2", percentage_discount: 10, threshold: 3, merchant_id: @merchant1.id)
    @discount3 = BulkDiscount.create!(name: "Discount 3", percentage_discount: 10, threshold: 3, merchant_id: @merchant2.id)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
    @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
    @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
    @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
    @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Kuhn')

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    visit merchant_bulk_discounts_path(@merchant1)
  end

  describe 'user_story_1' do 
    it 'has all the merchants bulk discounts w/ percentage and threshold' do 
      within(".bulk_discounts") do 
        expect(page).to have_content("Discount 1")
        expect(page).to have_content("Discount 2")
        expect(page).to have_content(@discount1.threshold)
        expect(page).to have_content(@discount2.threshold)
        expect(page).to have_content(@discount1.percentage_discount)
        expect(page).to have_content(@discount2.percentage_discount)
        expect(page).to_not have_content(@discount3.name)
        
      end
    end

    it 'has a link for each discount to its show page' do 
      within("#discount_#{@discount1.id}") do 
        expect(page).to have_link("Discount 1")
      end

      within(".bulk_discounts") do 
        expect(page).to have_link("Discount 1")
        expect(page).to have_link("Discount 2")
        expect(page).to_not have_link("Discount 3")
      end
    end

    it 'can naviagate to the bulk discounts show page' do 
      within("#discount_#{@discount1.id}") do 
        click_link("Discount 1")
      end
      expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@discount1.id}")
    end
  end
  describe 'user_story_2' do 
    it 'has a link to create a new discount' do 
      expect(page).to have_link("Create New Discount")
    end

    it 'after clicking the link, takes me to a new page to make a new bulk discount' do 
      click_link("Create New Discount")
      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
    end
  end

  describe 'user_story_3' do 
    it 'has a link to delete next to each bulk discount' do 
      within("#discount_#{@discount1.id}") do 
        expect(page).to have_link("Delete")
      end
    end

    it 'when clicked, it redirects to bulk discount index where the discount is not listed' do 
      within(".bulk_discounts") do 
        expect(page).to have_link("Discount 1")
        expect(page).to have_link("Discount 2")
        expect(page).to_not have_link("Discount 3")
      end

      within("#discount_#{@discount1.id}") do 
        click_link("Delete #{@discount1.name}")
      end
      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
      expect(BulkDiscount.exists?(@discount1.id)).to be(false)

      within(".bulk_discounts") do 
        expect(page).to have_link("Discount 2")
        expect(page).to_not have_link("Discount 1")
        expect(page).to_not have_link("Discount 3")
      end 
    end
  end

  describe 'user_story_9' do 
    it 'hs a section of upcoming holidays showing name and date for 3 upcoming holidays' do 
      within(".upcoming_holidays") do 
        expect(page).to have_content("Juneteenth")
        expect(page).to have_content("Good Friday")
        expect(page).to have_content("Memorial Day")
        expect(page).to have_content("2023-04-07")
        expect(page).to have_content("2023-05-29")
        expect(page).to have_content("2023-06-19")
        expect(page).to_not have_content("Christmas")
        expect(page).to_not have_content("2023-12-25")

      end
    end
  end
end