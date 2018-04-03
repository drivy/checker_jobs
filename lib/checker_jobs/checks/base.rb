CheckerJobs::Checks::Base = Struct.new(:klass, :name, :options, :block) do
  def perform
    result = CheckerJobs.configuration.around_check.call do
      klass.new.instance_exec(&block)
    end

    result.tap { |res| handle_result(res) }
  end

  private

  def notify(count:, entries: nil)
    CheckerJobs.configuration.emails_backend_class.
      new(self, count, entries).
      notify
  end

  def handle_result(_result)
    raise NotImplementedError
  end
end
