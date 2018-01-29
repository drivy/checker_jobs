require "action_mailer"
require "checker_jobs"
require "pry-byebug"
require "sidekiq"
require "sidekiq/testing"

ActionMailer::Base.delivery_method = :test
Sidekiq::Testing.inline!

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
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
      c.emails_backend = :action_mailer
      c.emails_options = { from: "oss@drivy.com", reply_to: "no-reply@drivy.com" }
      c.repository_url = { github: "drivy/checker_jobs" }
    end
  end

  config.before(:each, :email) do
    ActionMailer::Base.deliveries.clear
  end
end
