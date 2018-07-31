require "checker_jobs/emails_backends"
require "checker_jobs/jobs_processors"

class CheckerJobs::Configuration
  DEFAULT_TIME_BETWEEN_CHECKS = 15 * 60 # 15 minutes, expressed in seconds

  NOTIFIER_CLASSES = {
    email:          "CheckerJobs::Notifiers::Email",
    logger:         "CheckerJobs::Notifiers::Logger",
  }.freeze

  attr_accessor :jobs_processor,
                :notifiers_options,
                :time_between_checks,
                :repository_url,
                :around_check

  def self.default
    new.tap do |config|
      config.notifiers_options = {}
      config.time_between_checks = DEFAULT_TIME_BETWEEN_CHECKS
      config.around_check = ->(&block) { block.call }
    end
  end

  def notifier(notifier_symbol)
    options = {}
    yield(options)
    @notifiers_options[notifier_symbol] = options
  end

  def jobs_processor_module
    case jobs_processor
    when :sidekiq
      CheckerJobs::JobsProcessors::Sidekiq
    else
      raise CheckerJobs::UnsupportedConfigurationOption.new(:jobs_processor, jobs_processor)
    end
  end

  def notifier_class(notifier)
    notifier_class_name = NOTIFIER_CLASSES.fetch(notifier) do
      raise CheckerJobs::UnsupportedConfigurationOption.new(:notifier, notifier)
    end
    Object.const_get(notifier_class_name)
  end
end
