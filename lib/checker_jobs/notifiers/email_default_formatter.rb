class CheckerJobs::Notifiers::EmailDefaultFormatter
  include CheckerJobs::Notifiers::FormatterHelpers

  def initialize(check, count, entries)
    @check = check
    @count = count
    @entries = entries
  end

  def subject
    "#{human_check_name} checker found #{@count} element(s)"
  end

  def body
    body = "<p>See more about this email on <a href='#{repository_url}'>Github</a>.</p>"
    if @entries
      body += "<p>Found %<class_name>s are: <ul>%<html_ids>s</ul></p>" % {
        class_name: @entries.first.class.name,
        html_ids: @entries.map { |entry| "<li>#{format_entry(entry)}</li>" }.join,
      }
    end
    body
  end

  private

  def format_entry(entry) # rubocop:disable Lint/UselessMethodDefinition
    # NOTE: inherit and override to support your custom objects
    super
  end
end
