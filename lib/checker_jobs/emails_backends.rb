module CheckerJobs::EmailsBackends
  autoload :ActionMailer,     "checker_jobs/emails_backends/action_mailer"
  autoload :DefaultFormatter, "checker_jobs/emails_backends/default_formatter"
end
