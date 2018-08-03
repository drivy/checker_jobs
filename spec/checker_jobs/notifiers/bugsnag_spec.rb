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
    allow(::Bugsnag).to receive(:notify)
    perform
    expect(::Bugsnag).to have_received(:notify).once
  end

  describe "notify's arguments" do
    subject(:notify_arguments) do
      [].tap do |captured_args|
        allow(::Bugsnag).to receive(:notify).and_wrap_original do |_method, *args|
          captured_args.concat(args)
        end

        perform
      end
    end

    describe "the first argument" do
      subject(:first_argument) { notify_arguments.first }

      it "is an Error and have an explicit message" do
        expect(first_argument).to have_attributes(
          class: described_class::Error,
          message: "(#{checker_klass}) Ensure name was triggered!"
        )
      end
    end

    describe "the second argument" do
      subject(:second_argument) { notify_arguments.second }

      it "is an Error and have an explicit message" do # rubocop:disable RSpec/ExampleLength
        expect(second_argument).to match({
          severity: "warning",
          context: "checker_jobs",
          grouping_hash: notify_arguments.first.message,
          triggered_check: {
            klass: checker_klass,
            name: instance.name,
            count: 5,
            entries: nil,
            source_code_url: kind_of(String),
          },
        })
      end
    end
  end
end
