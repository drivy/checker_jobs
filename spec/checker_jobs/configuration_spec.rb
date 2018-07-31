RSpec.describe CheckerJobs::Configuration do
  let(:instance) { described_class.new }

  describe ".default" do
    subject(:default) { described_class.default }

    it "returns an instance of Configuration" do
      expect(default).to be_a described_class
    end

    it "returns a different (new) instance every call" do
      other_default = described_class.default
      expect(default).not_to be other_default
    end

    describe "the default time_between_checks value" do
      subject(:time_between_checks) { default.time_between_checks }

      it { is_expected.to eq described_class::DEFAULT_TIME_BETWEEN_CHECKS }
    end

    describe "the default around_check value" do
      subject(:around_check) { default.around_check }

      let(:check) { instance_spy(CheckerJobs::Checks::Base) }

      it "calls #call its block argument when called" do
        around_check.call { check.perform }
        expect(check).to have_received(:perform)
      end
    end
  end

  describe "#jobs_processor_module" do
    subject(:jobs_processor_module) { instance.jobs_processor_module }

    context "when jobs_processor isn't supported (or unset)" do
      before { instance.jobs_processor = :active_job }

      it do
        expect { jobs_processor_module }.
          to raise_error CheckerJobs::UnsupportedConfigurationOption
      end
    end

    context "when jobs_processor is set to :sidekiq" do
      before { instance.jobs_processor = :sidekiq }

      it { is_expected.to be CheckerJobs::JobsProcessors::Sidekiq }
    end
  end

  describe "#notifier_class" do
    context "when notifier isn't supported (or unset)" do
      it do
        expect { instance.notifier_class(:test) }.
          to raise_error CheckerJobs::UnsupportedConfigurationOption
      end
    end

    context "when notifier is set to :email" do
      it do
        expect(instance.notifier_class(:email)).to be(CheckerJobs::Notifiers::Email)
      end
    end
  end
end
