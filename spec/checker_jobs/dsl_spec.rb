RSpec.describe CheckerJobs::DSL do
  let(:instance) { Class.new { include CheckerJobs::DSL }.new }
  let(:key) { Object.new }
  let(:default) { Object.new }
  let(:target) { Object.new }
  let(:duration) { Object.new }

  #
  # Private API
  #

  describe "#option" do
    subject(:get_option) { instance.option(key, default) }

    it { is_expected.to be default }

    context "with #options been set including key" do
      before { instance.options key => :value }

      it { is_expected.to be :value }
    end
  end

  describe "#notification_target" do
    subject(:get_notification_target) { instance.notification_target }

    context "without prior call to #notify" do
      it do
        expect { get_notification_target }.to raise_error CheckerJobs::MissingNotificationTarget
      end
    end

    context "with a prior call to #notify" do
      before { instance.notify(target) }

      it { is_expected.to be target }
    end
  end

  describe "#time_between_checks" do
    subject(:get_time_between_checks) { instance.time_between_checks }

    context "without prior call to #interval" do
      before { CheckerJobs.configure }

      it { is_expected.to be CheckerJobs.configuration.time_between_checks }
    end

    context "with a prior call to #interval" do
      before { instance.interval(duration) }

      it { is_expected.to be duration }
    end
  end

  #
  # DSL
  #

  describe "#options" do
    subject(:set_options) { instance.options(hash) }

    let(:hash) { { key: :value } }

    it "defines options and allow retrieval through the #option method" do
      set_options
      expect(instance.option(:key)).to be :value
    end
  end

  describe "#notify" do
    subject(:set_notification_target) { instance.notify(target) }

    it "updates #notification_target" do
      set_notification_target
      expect(instance.notification_target).to be target
    end
  end

  describe "#interval" do
    subject(:set_time_between_checks) { instance.interval(duration) }

    it "updates #time_between_checks" do
      set_time_between_checks
      expect(instance.time_between_checks).to be duration
    end
  end
end
