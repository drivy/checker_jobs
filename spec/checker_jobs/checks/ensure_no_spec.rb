require "support/email_helpers"

RSpec.describe CheckerJobs::Checks::EnsureNo, :email, :configuration do
  include EmailHelpers

  let(:instance) { described_class.new(checker_klass, "ensure_name", {}, block) }
  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify :email, to: "oss@drivy.com"
    end
  end

  describe "#perform" do
    subject(:perform) { instance.perform }

    context "when block's result is 0" do
      let(:block) { Proc.new { 0 } }

      it { doesn_t_send_any_email }
    end

    context "when block's result is an empty enumerable" do
      let(:block) { Proc.new { [] } }

      it { doesn_t_send_any_email }
    end

    context "when block's result is > 0" do
      let(:block) { Proc.new { 2 } }

      it { sends_an_email }
    end

    context "when block's result is a non-empty enumerable" do
      let(:block) { Proc.new { [1, 2] } }

      it { sends_an_email }
    end
  end
end
