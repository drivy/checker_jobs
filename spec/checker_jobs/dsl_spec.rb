RSpec.describe CheckerJobs::DSL do
  let(:instance) { Class.new { include CheckerJobs::DSL }.new }

  let(:key) { Object.new }
  let(:block) { Proc.new {} }
  let(:target) { Object.new }
  let(:default) { Object.new }
  let(:options) { Object.new }
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

  shared_examples "ensure method" do
    subject(:ensure_method_name) do
      instance.__send__(method_name, :name, options, &block)
    end

    it "adds check_class into checks['name']" do
      ensure_method_name
      expect(instance.checks["name"]).to be_a check_class
    end

    it "sets attributes of the check's instance" do
      ensure_method_name
      expect(instance.checks["name"]).to have_attributes(klass: instance.class,
                                                         name: "name",
                                                         options: options,
                                                         block: block)
    end

    context "when name is already used" do
      before { instance.ensure_no(:name, options, &block) }

      it { expect { ensure_method_name }.to raise_error(CheckerJobs::DuplicateCheckerName) }
    end
  end

  describe "#ensure_no" do
    let(:method_name) { "ensure_no" }
    let(:check_class) { CheckerJobs::Checks::EnsureNo }

    include_examples "ensure method"
  end

  describe "#ensure_more" do
    let(:method_name) { "ensure_more" }
    let(:check_class) { CheckerJobs::Checks::EnsureMore }

    include_examples "ensure method"
  end

  describe "#ensure_fewer" do
    let(:method_name) { "ensure_fewer" }
    let(:check_class) { CheckerJobs::Checks::EnsureFewer }

    include_examples "ensure method"
  end
end
