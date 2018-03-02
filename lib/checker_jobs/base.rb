require "checker_jobs/dsl"

module CheckerJobs::Base
  def self.included(base)
    base.extend(CheckerJobs::DSL)
    base.include(CheckerJobs.configuration.jobs_processor_module)
  end
end
