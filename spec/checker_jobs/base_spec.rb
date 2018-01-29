RSpec.describe CheckerJobs::Base, :configuration do
  let(:jobs_processor_module) { CheckerJobs.configuration.jobs_processor_module }

  describe "when CheckerJobs::Base is inherited" do
    let(:klass) { Class.new(described_class) }

    it "extends klass with CheckerJobs::DSL" do
      expect(klass).to be_a CheckerJobs::DSL
    end

    it "includes the jobs_processor_module to klass" do
      expect(klass.included_modules).to include jobs_processor_module
    end
  end
end
