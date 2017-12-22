#
# Configuration
#

require "sidekiq"
require "sidekiq/testing"

Sidekiq::Testing.inline!

require "action_mailer"

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = { :address => "localhost", :port => 1025 }
# Be sure to run `mailcatcher` to see the actual emails on this example

require "checker_jobs"

CheckerJobs.configure do |config|
  config.repository_url = { github: "drivy/checker_jobs" }

  config.jobs_processor = :sidekiq

  config.emails_backend = :action_mailer
  config.emails_options = { from: "oss@drivy.com", reply_to: "no-reply@drivy.com" }
  config.emails_targets = { target_alias: "oss@drivy.com" }
end

#
# Checker
#

class UserChecker < CheckerJobs::Base
  options sidekiq: { queue: :fast }

  notify :target_alias

  ensure_no :inconsistent_payment do
    UserRepository.missing_email.size
  end
end

#
# Context
#

module UserRepository
  def self.missing_email
    [ User.new(1) ]
  end
end

User = Struct.new(:id)

#
# Triggering the checker
#

UserChecker.perform_async
