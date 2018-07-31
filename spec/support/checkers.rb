RSpec.shared_context "when SidekiqChecker is available" do
  let(:sidekiq_checker) { sidekiq_checker_klass.new }
  let(:sidekiq_checker_klass) do
    CheckerJobs.configure do |config|
      config.jobs_processor = :sidekiq
    end

    Class.new.tap do |klass|
      klass.include CheckerJobs::Base
      klass.options sidekiq: { queue: :fast }
      klass.notify :email, to: "oss@drivy.com"

      stub_const("SidekiqChecker", klass)
    end
  end
end
