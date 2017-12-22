require "checker_jobs/dsl"

class CheckerJobs::Base
  def self.inherited(base)
    base.extend(CheckerJobs::DSL)
    base.include(CheckerJobs.configuration.jobs_processor_module)
  end
end
