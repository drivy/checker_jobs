module CheckerJobs::Notifiers
  autoload :Email,                  "checker_jobs/notifiers/email"
  autoload :EmailDefaultFormatter,  "checker_jobs/notifiers/email_default_formatter"
  autoload :Logger,                 "checker_jobs/notifiers/logger"
end
