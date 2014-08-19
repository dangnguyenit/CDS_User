# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    obj_user_if 1
    obj_id 1
    type ""
    user nil
  end
end
