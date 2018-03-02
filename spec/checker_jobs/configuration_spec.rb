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

    describe "the default emails_options value" do
      subject(:emails_options) { default.emails_options }

      it { is_expected.to eq({}) }
    end

    describe "the default emails_formatter_class value" do
      subject(:emails_formatter_class) { default.emails_formatter_class }

      it { is_expected.to eq CheckerJobs::EmailsBackends::DefaultFormatter }
    end

    describe "the default time_between_checks value" do
      subject(:time_between_checks) { default.time_between_checks }

      it { is_expected.to eq described_class::DEFAULT_TIME_BETWEEN_CHECKS }
    end

    describe "the default around_check value" do
      subject(:around_check) { default.around_check }

      let(:check) { instance_spy(CheckerJobs::Checks::Base) }

      it "calls #perform on its argument when called" do
        around_check.call(check)
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

  describe "#emails_backend_class" do
    subject(:emails_backend_class) { instance.emails_backend_class }

    context "when emails_backend isn't supported (or unset)" do
      before { instance.emails_backend = :mailer }

      it do
        expect { emails_backend_class }.
          to raise_error CheckerJobs::UnsupportedConfigurationOption
      end
    end

    context "when emails_backend is set to :action_mailer" do
      before { instance.emails_backend = :action_mailer }

      it { is_expected.to be CheckerJobs::EmailsBackends::ActionMailer }
    end
  end
end
