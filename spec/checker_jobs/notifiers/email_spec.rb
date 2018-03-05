require "support/email_helpers"

RSpec.describe CheckerJobs::Notifiers::Email, :configuration, :email do
  include EmailHelpers

  let(:instance) do
    CheckerJobs::Checks::EnsureFewer.new(
      checker_klass, "ensure_name", { than: 3 }, Proc.new { 5 }
    )
  end

  let(:checker_klass) do
    Class.new do
      include CheckerJobs::Base
      notify :email, to: "oss@drivy.com"
    end
  end

  describe "with default" do
    subject(:perform) { instance.perform }

    it "sends an email" do
      sends_an_email
    end
  end

  describe "with wrong params" do
    subject(:perform) { instance.perform }

    let(:checker_klass) do
      Class.new do
        include CheckerJobs::Base
        notify :email, to: 42
      end
    end

    it "raises an exception" do
      expect { perform }.to raise_error(CheckerJobs::InvalidNotifierOptions)
    end
  end
end
