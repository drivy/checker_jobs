require "checker_jobs/emails_backends"
require "checker_jobs/jobs_processors"

class CheckerJobs::Configuration
  DEFAULT_TIME_BETWEEN_CHECKS = 15 * 60 # 15 minutes, expressed in seconds

  attr_accessor :jobs_processor,
                :emails_backend,
                :emails_options,
                :emails_formatter_class,
                :time_between_checks,
                :repository_url,
                :around_check

  def self.default
    new.tap do |config|
      config.emails_options = {}
      config.emails_formatter_class = CheckerJobs::EmailsBackends::DefaultFormatter
      config.time_between_checks = DEFAULT_TIME_BETWEEN_CHECKS
      config.around_check = ->(&block) { block.call }
    end
  end

  def jobs_processor_module
    case jobs_processor
    when :sidekiq
      CheckerJobs::JobsProcessors::Sidekiq
    else
      raise CheckerJobs::UnsupportedConfigurationOption.new(:jobs_processor, jobs_processor)
    end
  end

  def emails_backend_class
    case emails_backend
    when :action_mailer
      CheckerJobs::EmailsBackends::ActionMailer
    else
      raise CheckerJobs::UnsupportedConfigurationOption.new(:emails_backend, emails_backend)
    end
  end
end
