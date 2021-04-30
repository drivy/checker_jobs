require "support/checkers"

RSpec.describe CheckerJobs::JobsProcessors::Sidekiq, :configuration do
  describe "when CheckerJobs::JobsProcessors::Sidekiq is included" do
    let(:klass) { Class.new.tap { |k| k.include described_class } }

    it "extends klass with CheckerJobs::JobsProcessors::Sidekiq::ClassMethods" do
      expect(klass).to be_a CheckerJobs::JobsProcessors::Sidekiq::ClassMethods
    end

    it "includes Sidekiq::Worker to klass" do
      expect(klass.included_modules).to include Sidekiq::Worker
    end
  end

  describe "#perform(check_name)" do
    subject(:perform_with_arg) { sidekiq_checker.perform("check_name") }

    include_context "when SidekiqChecker is available"

    before { allow(sidekiq_checker_klass).to receive(:perform_check).and_call_original }

    context "when a check name matches the argument" do
      before { sidekiq_checker_klass.ensure_no(:check_name) { 0 } }

      it "calls SidekiqChecker.perform_check with the check's name" do
        perform_with_arg
        expect(sidekiq_checker_klass).to have_received(:perform_check).with("check_name")
      end
    end

    context "when no check are called like the given argument" do
      it { expect { perform_with_arg }.to raise_error(KeyError) }
    end
  end

  describe "#perform()" do
    subject(:perform) { sidekiq_checker.perform }

    include_context "when SidekiqChecker is available"

    before { allow(sidekiq_checker_klass).to receive(:client_push).and_call_original }

    context "when there is checks in the checker" do
      before do
        sidekiq_checker_klass.ensure_no(:first_check) { 0 }
        sidekiq_checker_klass.ensure_no(:second_check) { 0 }
      end

      it "pushes a job per check to Sidekiq" do
        perform

        first_item = { "class" => sidekiq_checker_klass, "args" => ["first_check"] }
        expect_in_sidekiq(a_hash_including(first_item))

        second_item = { "class" => sidekiq_checker_klass, "args" => ["second_check"] }
        expect_in_sidekiq(a_hash_including(second_item))
      end

      # A bit boring because I may need to introduce Timecop or something
      xit "pushes jobs at time_between_checks intervals"
    end

    context "when there is a check with a custom queue" do
      before { sidekiq_checker_klass.ensure_no(:check, queue: q) { 0 } }

      let(:q) { "average" }

      it "adds the queue the the item pushed through Sidekiq" do
        perform

        item = { "class" => sidekiq_checker_klass, "args" => ["check"], "queue" => q }
        expect_in_sidekiq(a_hash_including(item))
      end
    end

    def expect_in_sidekiq(expected_item)
      expect(sidekiq_checker_klass).to have_received(:client_push).with(expected_item)
    end
  end
end
