class CheckerJobs::Checks::EnsureNo < CheckerJobs::Checks::Base
  private

  def handle_result(result)
    case result
    when Numeric
      notify(count: result) if result.positive?
    when Enumerable
      notify(count: result.size, entries: result) if result.any?
    else
      raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_no'"
    end
  end
end
