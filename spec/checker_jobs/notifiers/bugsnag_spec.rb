RSpec.describe CheckerJobs::Notifiers::Bugsnag, :configuration do
  subject(:perform) { instance.perform }

  let(:instance) do
    CheckerJobs::Checks::EnsureFewer.new(
      checker_klass, "ensure_name", { than: 3 }, Proc.new { 5 }
    )
  end

  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify :bugsnag
    end
  end

  it "notifies bugsnag" do
    allow(::Bugsnag).to receive(:deliver_notification)
    perform
    expect(::Bugsnag).to have_received(:deliver_notification).once
  end

  describe "notify's resulting payload" do
    subject(:notify_report) do
      report = nil

      allow(::Bugsnag).to(receive(:deliver_notification).and_wrap_original { |_, r| report = r })

      perform

      report
    end

    # rubocop:disable RSpec/ExampleLength
    it "is an Error and have an explicit message", aggregate_failures: true do
      expect(notify_report.context).to eq "checker_jobs"
      expect(notify_report.severity).to eq "warning"
      expect(notify_report.grouping_hash).to eq "(#{checker_klass}) Ensure name was triggered!"
      expect(notify_report.exceptions.first).to match a_hash_including({
        errorClass: described_class::Error.to_s,
        message: "(#{checker_klass}) Ensure name was triggered!",
      })
      expect(notify_report.meta_data).to match({
        "triggered_check" => {
          klass: kind_of(Class),
          name: instance.name,
          count: 5,
          entries: nil,
          source_code_url: kind_of(String),
        },
      })
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
