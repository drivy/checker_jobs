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
end
