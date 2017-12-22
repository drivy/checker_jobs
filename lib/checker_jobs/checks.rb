module CheckerJobs::Checks
  autoload :Base,        "checker_jobs/checks/base"
  autoload :EnsureFewer, "checker_jobs/checks/ensure_fewer"
  autoload :EnsureMore,  "checker_jobs/checks/ensure_more"
  autoload :EnsureNo,    "checker_jobs/checks/ensure_no"
end
