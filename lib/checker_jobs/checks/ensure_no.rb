class CheckerJobs::Checks::EnsureNo < CheckerJobs::Checks::Base
  private

  def handle_result(result)
    case result
    when Numeric
      notify(count: result) unless result.zero?
    when Enumerable
      notify(count: result.size, entries: result) unless result.empty?
    else
      raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_no'"
    end
  end
end
