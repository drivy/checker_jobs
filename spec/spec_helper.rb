require "simplecov"
SimpleCov.start

require "action_mailer"
require "bugsnag"
require "checker_jobs"
require "pry-byebug"
require "sidekiq"
require "sidekiq/testing"

ActionMailer::Base.delivery_method = :test

Sidekiq::Testing.inline!

Bugsnag.configure do |config|
  # This API key is completely fake, it shouldn't be used.
  config.api_key = "11111111111111111111111111111111"
  config.release_stage = "production"
end

RSpec.configure do |config| # rubocop:disable Metrics/BlockLength
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.before(:context, :configuration) do
    CheckerJobs.configure do |c|
      c.jobs_processor = :sidekiq

      c.notifier :email do |options|
        options[:email_options] = {
          from: "oss@drivy.com", reply_to: "no-reply@drivy.com"
        }
        options[:formatter_class] = CheckerJobs::Notifiers::EmailDefaultFormatter
      end

      c.notifier :logger do |options|
        options[:logdev] = $stdout
        options[:level] = Logger::INFO
      end

      c.repository_url = { github: "drivy/checker_jobs" }
    end
  end

  config.before(:each, :email) do
    ActionMailer::Base.deliveries.clear
  end
end
