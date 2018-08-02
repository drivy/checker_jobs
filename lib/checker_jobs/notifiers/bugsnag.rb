require "action_mailer"

class CheckerJobs::Notifiers::Bugsnag
  include CheckerJobs::Notifiers::FormatterHelpers

  class Error < StandardError; end

  def initialize(check, count, entries)
    @check = check
    @metadata = {
      klass: @check.klass,
      name: @check.name,
      count: count,
      entries: entries,
    }
  end

  def notify
    raise Error, "(#{@check.klass}) #{human_check_name} was triggered!"
  rescue Error => error
    ::Bugsnag.notify(error, {
      severity: "warning",
      triggered_check: @metadata,
    })
  end
end
