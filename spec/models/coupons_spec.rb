require 'rails_helper'

RSpec.describe 'Coupons', type: :request do
  let(:merchant) { create(:merchant) }
  let(:coupon) { create(:coupon, merchant: merchant) }

  describe 'GET /api/v1/merchants/:merchant_id/coupons/:id' do
    context 'with Faker-generated data' do
      before { get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}" }

      it 'returns correctly formatted Faker data' do
        expect(response).to have_http_status(200)
        
        json = JSON.parse(response.body, symbolize_names: true)
        attributes = json[:data][:attributes]
        
        expect(attributes[:name]).to be_present
        expect(attributes[:code]).to match(/\A[A-Z0-9]{8}\z/)
        expect(%w[active inactive]).to include(attributes[:status])
        expect(%w[percent_off dollar_off]).to include(attributes[:discount_type])
        
        if attributes[:discount_type] == 'percent_off'
          expect(attributes[:discount_value]).to be_between(5, 50).inclusive
        else
          expect(attributes[:discount_value]).to be_between(5, 100).inclusive
        end
      end
    end

    context 'GET show' do
      before { get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}" }
    
      it 'returns a specific coupon' do
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body, symbolize_names: true)
        
        expect(json[:data][:id]).to eq(coupon.id.to_s)
        expect(json[:data][:attributes][:name]).to eq(coupon.name)
        expect(json[:data][:attributes][:times_used]).to eq(0) # No invoices yet
      end
    end

    describe 'GET index' do
      let!(:coupons) { create_list(:coupon, 3, merchant: merchant) }
    
      before { get "/api/v1/merchants/#{merchant.id}/coupons" }
    
      it 'returns all merchant coupons' do
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body, symbolize_names: true)
        
        expect(json[:data].count).to eq(3)
        expect(json[:data].first[:attributes][:merchant_id]).to eq(merchant.id)
      end
    end

    describe 'POST create' do
      context 'with valid params' do
        let(:valid_params) do
          { 
            coupon: {
              name: "Holiday Sale",
              code: "HOLIDAY20",
              status: "inactive",
              discount_type: "percent_off",
              discount_value: 20
            }
          }
        end
    
        it 'creates a new coupon' do
          expect {
            post "/api/v1/merchants/#{merchant.id}/coupons", params: valid_params
          }.to change(Coupon, :count).by(1)
    
          expect(response).to have_http_status(:created)
          expect(json[:data][:attributes][:code]).to eq("HOLIDAY20")
        end
      end
    
      context 'with invalid params' do
        it 'returns error for missing name' do
          post "/api/v1/merchants/#{merchant.id}/coupons", 
               params: { coupon: { code: "TEST", discount_type: "percent_off" } }
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json[:errors]).to include("Name can't be blank")
        end
      end
    end

    describe 'PATCH deactivate/activate' do
      let(:active_coupon) { create(:coupon, merchant: merchant, status: 'active') }
      let(:inactive_coupon) { create(:coupon, merchant: merchant, status: 'inactive') }
    
      context 'deactivate' do
        it 'changes status to inactive' do
          patch "/api/v1/merchants/#{merchant.id}/coupons/#{active_coupon.id}/deactivate"
          
          expect(response).to have_http_status(200)
          expect(json[:data][:attributes][:status]).to eq('inactive')
          expect(active_coupon.reload.status).to eq('inactive')
        end
      end
    
      context 'activate' do
        before { create_list(:coupon, 4, merchant: merchant, status: 'active') }
    
        it 'activates when under limit' do
          patch "/api/v1/merchants/#{merchant.id}/coupons/#{inactive_coupon.id}/activate"
          
          expect(response).to have_http_status(200)
          expect(json[:data][:attributes][:status]).to eq('active')
        end
    
        it 'rejects when at max active coupons' do
          create(:coupon, merchant: merchant, status: 'active') # Now 5 active
          patch "/api/v1/merchants/#{merchant.id}/coupons/#{inactive_coupon.id}/activate"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json[:errors]).to include("Maximum of 5 active coupons reached")
        end
      end
    end

    describe 'GET /api/v1/merchants/:merchant_id/coupons' do
      let!(:active_coupons) { create_list(:coupon, 2, merchant: merchant, status: :active) }
      let!(:inactive_coupons) { create_list(:coupon, 3, merchant: merchant, status: :inactive) }
    
      context 'with status=active' do
        before { get "/api/v1/merchants/#{merchant.id}/coupons", params: { status: 'active' } }
    
        it 'returns only active coupons' do
          expect(json[:data].count).to eq(2)
          expect(json[:data].pluck(:attributes).pluck(:status)).to all(eq('active'))
        end
      end
    end

    
  end
end