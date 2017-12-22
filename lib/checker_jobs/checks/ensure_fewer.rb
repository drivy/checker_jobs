class CheckerJobs::Checks::EnsureFewer < CheckerJobs::Checks::Base
  private

  def handle_result(result)
    case result
    when Numeric
      notify(count: result) if result > options.fetch(:than)
    else
      raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_less'"
    end
  end
end
