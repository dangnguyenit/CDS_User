# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :short_term_objective do
    short_term "MyText"
    action_plan "MyText"
    target_date "2014-05-20 16:44:44"
    current_title nil
  end
end
