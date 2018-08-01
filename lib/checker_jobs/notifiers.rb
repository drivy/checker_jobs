module CheckerJobs::Notifiers
  autoload :Bugsnag,                "checker_jobs/notifiers/bugsnag"
  autoload :Email,                  "checker_jobs/notifiers/email"
  autoload :EmailDefaultFormatter,  "checker_jobs/notifiers/email_default_formatter"
  autoload :FormatterHelpers,       "checker_jobs/notifiers/formatter_helpers"
  autoload :Logger,                 "checker_jobs/notifiers/logger"
end
