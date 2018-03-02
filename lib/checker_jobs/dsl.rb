require "checker_jobs/checks"

# DSL to declare checker jobs. It provides predicates:
#
# - ensure_no
# - ensure_more
# - ensure_fewer
#
# And configuration methods:
#
# - options
# - notify
# - interval
module CheckerJobs::DSL
  def options(options_hash)
    @options = options_hash
  end

  def notify(target)
    @notification_target = target
  end

  def interval(duration)
    @time_between_checks = duration
  end

  def ensure_no(name, options = {}, &block)
    add_check CheckerJobs::Checks::EnsureNo, name, options, block
  end

  def ensure_more(name, options = {}, &block)
    add_check CheckerJobs::Checks::EnsureMore, name, options, block
  end

  def ensure_fewer(name, options = {}, &block)
    add_check CheckerJobs::Checks::EnsureFewer, name, options, block
  end

  #
  # Private API
  #

  def notification_target
    raise CheckerJobs::MissingNotificationTarget, self.class unless defined?(@notification_target)

    @notification_target
  end

  def time_between_checks
    @time_between_checks || CheckerJobs.configuration.time_between_checks
  end

  def option(key, default = nil)
    @options && @options[key] || default
  end

  def checks
    @check ||= {}
  end

  def add_check(klass, name, options, block)
    name = name.to_s

    raise CheckerJobs::DuplicateCheckerName, name if checks.key?(name)

    checks[name] = klass.new(self, name, options, block)
  end

  def perform_check(check_name)
    check = checks.fetch(check_name.to_s)
    CheckerJobs.configuration.around_check.call(check)
  end
end
