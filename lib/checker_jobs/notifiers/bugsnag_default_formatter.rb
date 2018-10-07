class CheckerJobs::Notifiers::BugsnagDefaultFormatter
  include CheckerJobs::Notifiers::FormatterHelpers

  def initialize(check, count, entries)
    @check = check
    @count = count
    @entries = entries
  end

  def base_error
    CheckerJobs::Notifiers::Bugsnag::Error.new(error_message)
  end

  def severity
    "warning"
  end

  def context
    "checker_jobs"
  end

  def grouping_hash
    error_message
  end

  def tab_infos
    ["triggered_check", triggered_check]
  end

  private

  def triggered_check
    {
      klass: @check.klass,
      name: @check.name,
      count: @count,
      entries: @entries&.map { |entry| format_entry(entry) },
      source_code_url: repository_url,
    }
  end

  def error_message
    "(#{@check.klass}) #{human_check_name} was triggered!"
  end
end
