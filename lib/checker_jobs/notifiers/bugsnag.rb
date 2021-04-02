class CheckerJobs::Notifiers::Bugsnag < CheckerJobs::Notifiers::Base
  class Error < StandardError; end

  def initialize(check, count, entries)
    super

    @formatter = formatter_class.new(check, count, entries)
  end

  def notify
    raise @formatter.base_error
  rescue Error => e
    ::Bugsnag.notify(e) do |notification|
      notification.severity = @formatter.severity
      notification.context = @formatter.context
      notification.grouping_hash = @formatter.grouping_hash
      notification.add_tab(*@formatter.tab_infos)
    end
  end

  def self.default_options
    { formatter_class: CheckerJobs::Notifiers::BugsnagDefaultFormatter }
  end

  private

  def formatter_class
    notifier_options.fetch(:formatter_class)
  end
end
