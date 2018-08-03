require "logger"

class CheckerJobs::Notifiers::Logger
  include CheckerJobs::Notifiers::FormatterHelpers

  DEFAULT_LEVEL = Logger::INFO
  DEFAULT_LOGDEV = STDOUT

  def initialize(check, count, _entries)
    @check = check
    @count = count
    raise CheckerJobs::InvalidNotifierOptions unless valid?

    @logger = Logger.new(logdev)
    @logger.level = level
  end

  def notify
    @logger.add(level, format, human_check_name)
  end

  # override this
  def format
    "found #{@count} entries"
  end

  private

  def valid?
    (logdev.is_a?(String) || logdev.is_a?(IO)) &&
      [
        Logger::UNKNOWN, Logger::FATAL, Logger::ERROR,
        Logger::WARN, Logger::INFO, Logger::DEBUG
      ].include?(level)
  end

  def level
    @level ||=  @check.klass.notifier_options[:level] ||
                notifier_options[:level] ||
                DEFAULT_LEVEL
  end

  def logdev
    @logdev ||= @check.klass.notifier_options[:logdev] ||
                notifier_options[:logdev] ||
                DEFAULT_LOGDEV
  end

  def notifier_options
    CheckerJobs.configuration.notifiers_options[@check.klass.notifier]
  end
end
