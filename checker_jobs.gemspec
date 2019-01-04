lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "checker_jobs/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = "checker_jobs"
  spec.version       = CheckerJobs::VERSION
  spec.authors       = ["Drivy", "Nicolas Zermati"]
  spec.email         = ["oss@drivy.com"]

  spec.summary       = "Regression tests for data"
  spec.description   = ""
  spec.homepage      = "https://github.com/drivy/checker_jobs"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "actionmailer", "~> 5.0"
  spec.add_development_dependency "bugsnag"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "mailcatcher"
  spec.add_development_dependency "pronto"
  spec.add_development_dependency "pronto-rubocop"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "sidekiq", "~> 5.0"
  spec.add_development_dependency "simplecov"
end
