require "bundler/setup"

Bundler.setup

require "webmock/rspec"

require "what3words"

# RSpec.configure do |config|
#   # config.filter_run_excluding :integration => true
#
#   config.before(:all) do
#     WebMock.disable_net_connect!
#   end
# end
