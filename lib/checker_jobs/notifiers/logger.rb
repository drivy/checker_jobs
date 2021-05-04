require "logger"

class CheckerJobs::Notifiers::Logger < CheckerJobs::Notifiers::Base
  include CheckerJobs::Notifiers::FormatterHelpers

  def initialize(check, count, _entries)
    super

    @count = count
    raise CheckerJobs::InvalidNotifierOptions unless valid?

    @logger = Logger.new(logdev)
    @logger.level = level
  end

  def notify
    @logger.add(level, format, human_check_name)
  end

  def self.default_options
    {
      logdev: $stdout,
      level: Logger::INFO,
    }
  end

  private

  # override this
  def format
    "found #{@count} entries"
  end

  def valid?
    (logdev.is_a?(String) || logdev.is_a?(IO)) &&
      [
        Logger::UNKNOWN, Logger::FATAL, Logger::ERROR,
        Logger::WARN, Logger::INFO, Logger::DEBUG
      ].include?(level)
  end

  def level
    @level ||= @check.klass.notifier_options[:level] || notifier_options[:level]
  end

  def logdev
    @logdev ||= @check.klass.notifier_options[:logdev] || notifier_options[:logdev]
  end
end
