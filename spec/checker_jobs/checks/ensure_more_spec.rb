require "support/email_helpers"

RSpec.describe CheckerJobs::Checks::EnsureMore, :email, :configuration do
  include EmailHelpers

  let(:instance) { described_class.new(checker_klass, "ensure_name", { than: 3 }, block) }
  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify :email, to: "oss@drivy.com"
    end
  end

  describe "#perform" do
    subject(:perform) { instance.perform }

    context "when block's result is < options[:than]" do
      let(:block) { Proc.new { 2 } }

      it { sends_an_email }
    end

    context "when block's result is == options[:than]" do
      let(:block) { Proc.new { 3 } }

      it { doesn_t_send_any_email }
    end

    context "when block's result is > options[:than]" do
      let(:block) { Proc.new { 4 } }

      it { doesn_t_send_any_email }
    end
  end
end
