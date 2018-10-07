require "action_mailer"

class CheckerJobs::Notifiers::Email < CheckerJobs::Notifiers::Base
  def initialize(check, count, entries)
    super

    @formatter = formatter_class.new(check, count, entries)
    @defaults = { subject: @formatter.subject }

    raise CheckerJobs::InvalidNotifierOptions unless valid?
  end

  def notify
    Mailer.notify(@formatter.body, mailer_options).deliver!
  end

  def self.default_options
    {
      formatter_class: CheckerJobs::Notifiers::EmailDefaultFormatter,
      email_options: {},
    }
  end

  private

  def valid?
    mailer_options[:to].is_a?(String)
  end

  def mailer_options
    @mailer_options ||= @defaults.
                        merge(email_options).
                        merge(@check.klass.notifier_options)
  end

  def email_options
    notifier_options[:email_options]
  end

  def formatter_class
    notifier_options[:formatter_class]
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
