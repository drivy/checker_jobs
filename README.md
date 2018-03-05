# CheckerJobs

This gems provides a small DSL to check your data for inconsistencies.

[![Maintainability](https://api.codeclimate.com/v1/badges/7972bd0e4dc65329f5c6/maintainability)](https://codeclimate.com/github/drivy/checker_jobs/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/7972bd0e4dc65329f5c6/test_coverage)](https://codeclimate.com/github/drivy/checker_jobs/test_coverage)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'checker_jobs'
```

## Usage

Have a look at the `examples` directory of the repository to get a clearer idea
about how to use and the gem is offering.

### Configure

At the moment this gems supports [Drivy][gh-drivy]'s stack which includes
[Sidekiq][gh-sidekiq] and [Rails][rails]. It has been designed to supports more
than Sidekiq a job processor and more that ActionMailer as a notification
gateway. If you're on the same stack as we are, configuration looks like this:

``` ruby
require "checker_jobs"

CheckerJobs.configure do |config|
  config.repository_url = { github: "drivy/checker_jobs" }

  config.jobs_processor = :sidekiq

  config.emails_backend = :action_mailer
  config.emails_options = { from: "oss@drivy.com", reply_to: "no-reply@drivy.com" }
end

```

This piece of code usually goes into the `config/initializers/checker_jobs.rb`
file in a rails application. It relies on the fact that ActionMailer and sidekiq
are already configured.

If you're on a different stack and you'll like to add a new job processor or
notification backend in this gem, [drop us a line][d-jobs].

### Write checkers

A checker is a class that inherits `CheckerJobs::Base` and uses the
[DSL](wiki/DSL) to declare checks.

``` ruby
class UserChecker < CheckerJobs::Base
  options sidekiq: { queue: :fast }

  notify "tech@drivy.com"

  ensure_no :user_without_email do
    UserRepository.missing_email.size
  end
end
```

The `UserChecker` will have the same interface as your usual jobs. In this
example, `UserChecker` will be a `Sidekiq::Worker`. Its `#perform` method will
run the check named `:user_without_email` and if
`UserRepository.missing_email.size` is greater than 0 then an email will be
fired through ActionMailer to `tech@drivy.com`.

### Schedule checks

Once you have checker jobs, you'll need to run them. There are many task
schedulers out there and it isn't really relevant what you'll be using.

You have to enqueue you job as often as you like and that's it.

``` ruby
UserChecker.perform_async
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/drivy/checker_jobs.

You'll find out that the CI is setup to run test coverage and linting.

## License

The gem is available as open source under the terms of the [MIT License][licence].


[d-jobs]:     https://www.drivy.com/jobs
[gh-drivy]:   https://github.com/drivy
[gh-sidekiq]: https://github.com/mperham/sidekiq
[licence]:    http://opensource.org/licenses/MIT
[rails]:      http://rubyonrails.org
