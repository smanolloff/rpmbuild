require 'rpmbuild'

# support_files = File.expand_path("spec/support/**/*.rb")
# Dir[support_files].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true

  # config.include SpecSupport
  # config.mock_with :mocha
  # config.order = "random"

end

