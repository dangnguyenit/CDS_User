task :prepare_db_for_test => :environment do
  if (ENV['RAILS_ENV'] == "test")
    Rake::Task["db:test:prepare"].invoke
    Rake::Task["db:seed"].invoke

  else
    puts "Must be executed with test flag ('RAILS_ENV=test')"
  end
end