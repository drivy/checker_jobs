require "checker_jobs/version"
require "checker_jobs/errors"
require "checker_jobs/configuration"
require "checker_jobs/base"

module CheckerJobs
  def self.configuration
    @configuration || raise(Unconfigured)
  end

  def self.configure(&block)
    @configuration = Configuration.default.tap do |config|
      block&.call(config)
    end
  end
end
