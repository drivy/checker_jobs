require "sidekiq"

module CheckerJobs::JobsProcessors::Sidekiq
  def self.included(base)
    base.include(Sidekiq::Worker)
    base.extend(ClassMethods)
  end

  def perform(check_name = nil)
    # Run on specific check
    return self.class.perform_check(check_name.to_s) if check_name

    # Enqueue one specific check for each declared check
    self.class.checks.values.each.with_index do |check, index|
      scheduled_in = index * self.class.time_between_checks
      self.class.perform_check_in(check, scheduled_in)
    end
  end

  module ClassMethods
    # Overrides DSL#options in order to pass specific options to Sidekiq.
    # The options could be the queue the job processor must use, or other
    # middleware options of your choice.
    def options(*args)
      super(*args).tap do
        sidekiq_options option(:sidekiq, {})
      end
    end

    def perform_check_in(check, interval)
      # Borrowed from Sidekiq implementation
      item = {
        "class" => self,
        "args" => [check.name.to_s],
        "at" => Time.now.to_f + interval.to_f,
      }

      if (specific_queue = check.options[:queue])
        item["queue"] = specific_queue.to_s
      end

      client_push(item)
    end
  end
end
