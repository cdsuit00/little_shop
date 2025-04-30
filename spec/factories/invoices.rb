FactoryBot.define do
  factory :invoice do
    status { %w[completed in_progress cancelled].sample }
    merchant
    customer
    created_at { Faker::Time.between(from: 1.year.ago, to: Time.current) }
    updated_at { created_at }

    trait :with_coupon do
      association :coupon, factory: :coupon
    end
  end
end