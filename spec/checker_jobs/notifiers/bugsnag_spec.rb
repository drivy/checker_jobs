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
    allow(::Bugsnag::Notification).to receive(:deliver_exception_payload)
    perform
    expect(::Bugsnag::Notification).to have_received(:deliver_exception_payload).once
  end

  describe "notify's resulting payload" do
    subject(:notify_payload) do
      payload = nil

      # NOTE: To get compatibility with Bugsnag 6, we'll get the payload from elsewhere:
      # Bugsnag::Delivery[configuration.delivery_method].deliver(_, payload, _, _)
      allow(::Bugsnag::Notification).
        to receive(:deliver_exception_payload).
        and_wrap_original do |_method, _, p, _, _|
          payload = p[:events].first
        end

      perform

      payload
    end

    # rubocop:disable RSpec/ExampleLength
    it "is an Error and have an explicit message", aggregate_failures: true do
      # We hook deep into Bugsnag to ensure we send the right payload.
      # This ensure we're only compatible with Bugsnag 5 and not Bugsnag 6.
      expect(notify_payload[:context]).to eq "checker_jobs"
      expect(notify_payload[:severity]).to eq "warning"
      expect(notify_payload[:groupingHash]).to eq "(#{checker_klass}) Ensure name was triggered!"
      expect(notify_payload[:exceptions].first).to match a_hash_including({
        errorClass: described_class::Error.to_s,
        message: "(#{checker_klass}) Ensure name was triggered!",
      })
      expect(notify_payload[:metaData]).to match({
        triggered_check: {
          klass: kind_of(String),
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
