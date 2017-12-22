CheckerJobs::Checks::Base = Struct.new(:klass, :name, :options, :block) do
  def perform
    klass.new.instance_exec(&block).tap do |result|
      handle_result(result)
    end
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
