require 'rails/all'
require 'watir'
require 'watir-webdriver'
require 'test/unit'
class TestBase < Test::Unit::TestCase
  require File.expand_path('../../../config/boot', __FILE__)
  include Watir
  TestSetting = Hashie::Mash.new YAML.load(ERB.new(File.read(Rails.root.join("test", "unit", "config.yml"))).result)[Rails.env]
  @@browser = :firefox
  @@link = TestSetting.base_url
  @@login_link = TestSetting.base_url + TestSetting.login_path
  if ARGV.size > 0
      st = ARGV[0]
      @@browser = st[3..-1].to_sym
  end

  def setup

    # Set link to browse based on test
    case self.class.name
    when "TestLogin"
      @@link += TestSetting.login_path
    end

    #open browser and goto the the website
    @ff = Watir::Browser.new @@browser
    @ff.goto @@login_link
  end

  def teardown
    #close the browser
    @ff.close
  end

  def login(user_type)

    username = TestSetting.users["#{user_type}"].username
    password = TestSetting.users["#{user_type}"].password

    @ff.text_field(:name => "user[username]").set(username)
    @ff.text_field(:name => "user[password]").set(password)

    #Click Sign in
    @ff.button(:name, 'commit').click
  end
end