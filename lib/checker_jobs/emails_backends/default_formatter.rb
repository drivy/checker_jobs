class CheckerJobs::EmailsBackends::DefaultFormatter
  def initialize(check, count, entries)
    @check = check
    @count = count
    @entries = entries
  end

  def subject
    name = @check.name.tr("_", " ").capitalize
    "#{name} checker found #{@count} element(s)"
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

  GITHUB_URL_FORMAT = "https://github.com/%<repository>s/blob/master/%<path>s#L%<line>i".freeze

  def repository_url
    if repository_configuration.is_a?(String)
      repository_configuration
    elsif repository_configuration.key?(:github)
      github_url
    end
  end

  def github_url
    filepath, line_number = @check.block.source_location
    filepath = filepath.sub(Dir.pwd + "/", "")
    GITHUB_URL_FORMAT % {
      repository: repository_configuration[:github],
      path: filepath,
      line: line_number,
    }
  end

  def format_entry(entry)
    # NOTE: inherit and override to support your custom objects
    entry.respond_to?(:id) ? entry.id : entry
  end

  def repository_configuration
    CheckerJobs.configuration.repository_url
  end
end
