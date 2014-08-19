load 'deploy'
# Uncomment if you are using Rails' asset pipeline
    load 'deploy/assets'
load 'config/deploy' # remove this line to skip loading any of the default tasks

# load File.join(File.dirname(__FILE__), 'deploy.rb') if respond_to?(:namespace)
Dir[File.join(File.dirname(__FILE__),'lib/capistrano/recipes/*.rb')].each { |plugin| require(plugin) }
# load File.join(File.dirname(__FILE__), 'capistrano/plan.rb')
# load File.join(File.dirname(__FILE__), 'capistrano/deploy.rb')