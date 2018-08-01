# Needs a @check instance variable and provides the methods:
# - #repository_url
# - #human_check_name
module CheckerJobs::Notifiers::FormatterHelpers
  GITHUB_URL_FORMAT = "https://github.com/%<repository>s/blob/master/%<path>s#L%<line>i".freeze

  def human_check_name
    @check.name.tr("_", " ").capitalize
  end

  def repository_url
    if repository_configuration.is_a?(String)
      repository_configuration
    elsif repository_configuration.key?(:github)
      github_url
    end
  end

  private

  def github_url
    filepath, line_number = @check.block.source_location
    filepath = filepath.sub(Dir.pwd + "/", "")
    GITHUB_URL_FORMAT % {
      repository: repository_configuration[:github],
      path: filepath,
      line: line_number,
    }
  end

  def repository_configuration
    CheckerJobs.configuration.repository_url
  end
end
