# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance_comment do
    comment "MyText"
    type ""
    user nil
    instances_term nil
  end
end
