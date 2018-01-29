require "action_mailer"

class CheckerJobs::EmailsBackends::ActionMailer
  def initialize(check, count, entries)
    @check = check
    @formatter = formatter_class.new(check, count, entries)
  end

  def notify
    Mailer.notify(@formatter.body, options).deliver!
  end

  private

  def options
    CheckerJobs.configuration.emails_options.merge({
      to: @check.klass.notification_target,
      subject: @formatter.subject,
    })
  end

  def formatter_class
    CheckerJobs.configuration.emails_formatter_class
  end

  # Simple mailer class based on ActionMailer to send HTML emails while reusing
  # the ActionMailer configuration of the application embedding the checkers.
  class Mailer < ::ActionMailer::Base
    layout false

    def notify(body, options)
      mail(options) do |format|
        format.html { render html: body.html_safe }
      end
    end
  end
end
