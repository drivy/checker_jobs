require "checker_jobs/version"
require "checker_jobs/errors"
require "checker_jobs/configuration"
require "checker_jobs/base"

module CheckerJobs
  def self.configuration 
    Thread.current[:checker_jobs_configuration] || raise(Unconfigured)
  end

  def self.configure(&block)
    Thread.current[:checker_jobs_configuration] = Configuration.default
    block&.call(configuration)
  end
end
