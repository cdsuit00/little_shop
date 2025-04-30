FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code(digits: 2) }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase }
    status { %w[active inactive].sample }
    discount_type { %w[percent_off dollar_off].sample }
    discount_value { discount_type == 'percent_off' ? Faker::Number.between(from: 5, to: 50) : Faker::Number.between(from: 5, to: 100) }
    merchant
  end
end