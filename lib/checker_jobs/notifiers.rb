module CheckerJobs::Notifiers
  autoload :Base,                    "checker_jobs/notifiers/base"
  autoload :Bugsnag,                 "checker_jobs/notifiers/bugsnag"
  autoload :BugsnagDefaultFormatter, "checker_jobs/notifiers/bugsnag_default_formatter"
  autoload :Email,                   "checker_jobs/notifiers/email"
  autoload :EmailDefaultFormatter,   "checker_jobs/notifiers/email_default_formatter"
  autoload :FormatterHelpers,        "checker_jobs/notifiers/formatter_helpers"
  autoload :Logger,                  "checker_jobs/notifiers/logger"
end
