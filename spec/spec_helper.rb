require "bundler/setup"

Bundler.setup

require "webmock/rspec"

require "what3words"

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.allow_net_connect!
  end
end
