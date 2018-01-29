module CheckerJobs
  class Error < StandardError
  end

  class MissingNotificationTarget < Error
  end

  class Unconfigured < Error
    def message
      "CheckerJobs: are unconfigured, do CheckerJobs.configure before using it."
    end
  end

  class UnsupportedConfigurationOption < Error
    def initialize(option_name, value)
      @option_name = option_name
      @value = value
      super()
    end

    def message
      "CheckerJobs: unsupported configuration option: '#{@value.inspect}' " \
      "isn't valid for '#{@option_name}' option."
    end
  end

  class DuplicateCheckerName < Error
    def initialize(checker_name)
      @checker_name = checker_name
      super
    end

    def message
      "CheckerJobs: the name '#{checker_name}' is already used for another checker."
    end
  end
end
