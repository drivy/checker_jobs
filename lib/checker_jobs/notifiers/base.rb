class CheckerJobs::Notifiers::Base
  def initialize(check, _count, _entries)
    @check = check
  end

  def notify
    raise NotImplementedError
  end

  def self.default_options
    raise NotImplementedError
  end

  private

  def notifier_options
    CheckerJobs.configuration.notifiers_options.fetch(
      @check.klass.notifier,
      self.class.default_options,
    )
  end
end
