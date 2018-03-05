require "action_mailer"

class CheckerJobs::Notifiers::Email
  def initialize(check, count, entries)
    @check = check
    @formatter = formatter_class.new(check, count, entries)
    @defaults = { subject: @formatter.subject }

    raise CheckerJobs::InvalidNotifierOptions unless valid?
  end

  def notify
    Mailer.notify(@formatter.body, options).deliver!
  end

  private

  def valid?
    options[:to].is_a?(String)
  end

  def options
    @options ||=  @defaults.
                  merge(notifier_options[:email_options]).
                  merge(@check.klass.notifier_options)
  end

  def formatter_class
    notifier_options[:formatter_class] || CheckerJobs::Notifiers::EmailDefaultFormatter
  end

  def notifier_options
    CheckerJobs.configuration.notifiers_options[@check.klass.notifier]
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
