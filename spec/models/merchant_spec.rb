require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
    it { should have_many(:coupons) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
  
  describe "class methods" do
    before(:each) do
      @merchant1 = Merchant.create!(name: "Ring World Jewelers")
      @merchant2 = Merchant.create!(name: "Computer Store")
      @merchant3 = Merchant.create!(name: "Golden Rings")
      @merchant4 = Merchant.create!(name: "Silver Shop")
      @merchant5 = Merchant.create!(name: "Gold Shop")
    end
    
    describe ".search_by_name" do
      it "merchants that match name" do
        expect(Merchant.search_by_name("ring")).to contain_exactly(@merchant1, @merchant3)
      end
      
      it "cAsE sensitive" do
        expect(Merchant.search_by_name("RING")).to contain_exactly(@merchant1, @merchant3)
      end
      
      it "no matches" do
        expect(Merchant.search_by_name("nonexistent")).to be_empty
      end
    end
    
    describe ".search" do
      it "merchants name" do
        expect(Merchant.search({name: "ring"})).to contain_exactly(@merchant1, @merchant3)
      end
      
      it "no parameters" do
        expect(Merchant.search({})).to be_empty
      end
      
      it "all merchants alphabetically" do
        result = Merchant.search({all: true})

        expect(result).to match_array([@merchant1, @merchant2, @merchant3, @merchant4, @merchant5])
        expect(result.map(&:name)).to eq(["Computer Store", "Gold Shop", "Golden Rings", "Ring World Jewelers", "Silver Shop"])
      end
      
      it "cAsE sensitive" do
        expect(Merchant.search({name: "RING"})).to contain_exactly(@merchant1, @merchant3)
      end
    end
  end
end

RSpec.describe 'Merchant Invoices', type: :request do
  let(:merchant) { create(:merchant) }
  let(:customer) { create(:customer) }
  
  let!(:invoice_with_coupon) do
    create(:invoice, 
           merchant: merchant, 
           customer: customer,
           coupon: create(:coupon, merchant: merchant))
  end
  
  let!(:invoice_without_coupon) do
    create(:invoice, 
           merchant: merchant,
           customer: customer)
  end

  describe 'GET /api/v1/merchants/:id/invoices' do
    before { get "/api/v1/merchants/#{merchant.id}/invoices" }

    it 'returns all merchant invoices' do
      expect(response).to have_http_status(200)
      expect(json[:data].count).to eq(2)
    end

    it 'includes coupon_id when present' do
      invoice_data = json[:data].find { |i| i[:id] == invoice_with_coupon.id.to_s }
      expect(invoice_data[:attributes][:coupon_id]).to eq(invoice_with_coupon.coupon_id)
    end

    it 'omits coupon_id when not present' do
      invoice_data = json[:data].find { |i| i[:id] == invoice_without_coupon.id.to_s }
      expect(invoice_data[:attributes]).not_to have_key(:coupon_id)
    end
  end

  describe 'GET /api/v1/merchants' do
    let!(:merchant1) { create(:merchant) }
    let!(:merchant2) { create(:merchant) }
  
    before do
      create_list(:coupon, 3, merchant: merchant1)
      create_list(:invoice, 2, merchant: merchant1, coupon: merchant1.coupons.first)
      create_list(:invoice, 1, merchant: merchant1) # without coupon
      create_list(:coupon, 1, merchant: merchant2)
    end
  
    it 'returns merchants with coupon counts' do
      get '/api/v1/merchants'
      
      merchant1_data = json[:data].find { |m| m[:id] == merchant1.id.to_s }
      merchant2_data = json[:data].find { |m| m[:id] == merchant2.id.to_s }
      
      expect(merchant1_data[:attributes][:coupons_count]).to eq(3)
      expect(merchant1_data[:attributes][:invoices_with_coupons_count]).to eq(2)
      expect(merchant2_data[:attributes][:coupons_count]).to eq(1)
      expect(merchant2_data[:attributes][:invoices_with_coupons_count]).to eq(0)
    end
  end
end