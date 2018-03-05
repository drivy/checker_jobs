RSpec.describe CheckerJobs::Notifiers::Logger, :configuration do
  let(:instance) do
    CheckerJobs::Checks::EnsureFewer.new(
      checker_klass, "ensure_name", { than: 3 }, Proc.new { 5 }
    )
  end

  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify :logger
    end
  end

  context "with default" do
    it "logs" do
      expect do
        instance.perform
      end.to output(/INFO -- Ensure name: found 5 entries/).to_stdout_from_any_process
    end
  end

  context "with params" do
    let(:checker_klass) do
      Class.new do
        include CheckerJobs::Base
        notify :logger, level: Logger::FATAL, logdev: STDERR
      end
    end

    it "logs" do
      expect do
        instance.perform
      end.to output(/FATAL -- Ensure name: found 5 entries/).to_stderr_from_any_process
    end
  end

  context "with invalid log level" do
    let(:checker_klass) do
      Class.new do
        include CheckerJobs::Base
        notify :logger, level: "Picard"
      end
    end

    it "raises an exception" do
      expect { instance.perform }.to raise_error(CheckerJobs::InvalidNotifierOptions)
    end
  end
end
