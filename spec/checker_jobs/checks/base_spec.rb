RSpec.describe CheckerJobs::Checks::Base, :configuration do
  let(:instance) { subclass.new(checker_klass, "ensure_name", {}, block) }
  let(:subclass) { CheckerJobs::Checks::EnsureNo }
  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify "oss@drivy.com"
    end
  end


  describe "#perform" do
    subject(:perform) { instance.perform }

    let(:block) { Proc.new { self.class.notification_target.length } }

    it "executes the block in the context of a new klass's instance" do
      is_expected.to eq 13 # "oss@drivy.com".size
    end
  end
end
