RSpec.describe CheckerJobs::Checks::Base, :configuration do
  let(:instance) { subclass.new(checker_klass, "ensure_name", {}, block) }
  let(:subclass) { CheckerJobs::Checks::EnsureNo }
  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify :email, to: "oss@drivy.com"
    end
  end

  describe "#perform" do
    subject(:perform) { instance.perform }

    let(:block) do
      Proc.new { self.class.notifier_options[:to].length }
    end

    it "executes the block in the context of a new klass's instance" do
      expect(perform).to eq 13 # "oss@drivy.com".size
    end

    context "when there is an around_check" do
      before do
        allow(CheckerJobs.configuration).
          to receive(:around_check).
          and_return(around_check)
      end

      let(:around_check) do
        Proc.new do |&_block|
          0 # Don't call the block
        end
      end

      it "delegates the execution of the block to the around_check" do
        expect(perform).to be 0
      end

      it "keeps handling the result outside the around_check delegation" do
        allow(instance).to receive(:handle_result).and_call_original
        perform
        expect(instance).to have_received(:handle_result).with(0)
      end
    end
  end
end
