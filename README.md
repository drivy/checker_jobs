# CheckerJobs

This gems provides a small DSL to check your data for inconsistencies.

[![Gem Version](https://badge.fury.io/rb/checker_jobs.svg)](https://badge.fury.io/rb/checker_jobs)
[![Maintainability](https://api.codeclimate.com/v1/badges/7972bd0e4dc65329f5c6/maintainability)](https://codeclimate.com/github/drivy/checker_jobs/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/7972bd0e4dc65329f5c6/test_coverage)](https://codeclimate.com/github/drivy/checker_jobs/test_coverage)

## Introduction

To ensure database integrity, DBMS provides some tools: foreign keys, triggers,
strored procedures, ... Those tools aren't the easiests to maintain unless your
project is based on them. Also, you may want to avoid to duplicate your business
rules from your application to another language and add operational complexity
around deployment.

This gem doesn't aim to replace those tools but provides something else that
could serve a close purpose: _ensure that you work with the data you expect_.

This gem helps you schedule some verifications on your data and get alerts when
something is unexpected. You declare checks that could contain any business code
you like and then those checks are run by your application, in background jobs.

A small DSL is provided to helps you express your predicates:

- `ensure_no` will check that the result of a given block is `zero?` or `empty?`
- `ensure_more` will check that the result of a given block is `>=` than a given number
- `ensure_fewer` will check that the result of a given block is `<=` than a given number

and an easy way to configure notifications.

For instance, at Drivy we don't expect users to get a negative credit amount. It
isn't easy to get all the validation right because many rules are in play here.
Because of those rules the credit isn't just a column in our database yet but
needs to be computed based on various parameters. What we would like to ensure is
that _no one ends up with a negative credit_. We could write something like:

``` ruby
class UsersChecker
  include CheckerJobs::Base

  options sidekiq: { queue: :slow }

  notify :email, to: "oss@drivy.com"

  ensure_no :negative_rental_credit do
    # The following code is an over-simplification
    # Real code is more performance oriented...

    user_ids_with_negative_rental_credit = []

    User.find_each do |user|
      if user.credit_amount < 0
        user_ids_with_negative_rental_credit << user.id
      end
    end

    user_ids_with_negative_rental_credit
  end
end
```

Then when something's wrong, [you'll get alerted](https://cl.ly/3l2b3T3n0o2a).

You'll find more use cases and tips in the [wiki](https://github.com/drivy/checker_jobs/wiki).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'checker_jobs'
```

## Usage

Have a look at the examples directory of the repository to get a clearer idea about how to use and the gem is offering.

### Configure

``` ruby
require "checker_jobs"

CheckerJobs.configure do |c|
  c.jobs_processor = :sidekiq

  c.notifier :bugsnag do |options|
    options[:formatter_class] = CheckerJobs::Notifiers::BugsnagDefaultFormatter
  end

  c.notifier :email do |options|
    options[:formatter_class] = CheckerJobs::Notifiers::EmailDefaultFormatter
    options[:email_options] = {
      from: "oss@drivy.com",
      reply_to: "no-reply@drivy.com",
    }
  end

  c.notifier :logger do |options|
    options[:logdev] = STDOUT
    options[:level] = Logger::INFO
  end

  c.repository_url = { github: "drivy/checker_jobs" }
end

```

This piece of code usually goes into the `config/initializers/checker_jobs.rb`
file in a rails application. It relies on the fact that ActionMailer and sidekiq
are already configured.

If you're on a different stack and you'll like to add a new job processor or
notification backend in this gem, [drop us a line][d-jobs].

### Job Processor

At the moment, only [Sidekiq][gh-sidekiq] is supported as a job processor to asynchronously check for data inconsitencies.
The gem is designed to supports more processor.
PRs are appreciated 🙏

### Notifiers

We support different kind of notifiers, as of today we have the following:

- `:bugsnag`: uses `Bugsnag` to send notifications. It takes the global Bugsnag configuration.
- `:email`: uses `ActionMailer` to send emails. You can pass it any `ActionMailer` options.
- `:logger`: Uses `Logger` to output inconsitencies in the log. Takes the following params:
  - `logdev`: The log device. This is a filename (String) or IO object (typically STDOUT, STDERR, or an open file).
  - `level`: Logging severity threshold (e.g. Logger::INFO)

### Write checkers

A checker is a class that inherits `CheckerJobs::Base` and uses the
[DSL](wiki/DSL) to declare checks.

``` ruby
class UserChecker
  include CheckerJobs::Base

  options sidekiq: { queue: :fast }

  notify :email, to: "oss@drivy.com"

  ensure_no :user_without_email do
    UserRepository.missing_email.size
  end
end
```

The `UserChecker` will have the same interface as your usual jobs. In this
example, `UserChecker` will be a `Sidekiq::Worker`. Its `#perform` method will
run the check named `:user_without_email` and if
`UserRepository.missing_email.size` is greater than 0 then an email will be
fired through ActionMailer to `oss@drivy.com`.

### Schedule checks

Once you have checker jobs, you'll need to run them. There are many task
schedulers out there and it isn't really relevant what you'll be using.

You have to enqueue your job as often as you like and that's it.

``` ruby
UserChecker.perform_async
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/drivy/checker_jobs.

You'll find out that the CI is setup to run test coverage and linting.

## License

The gem is available as open source under the terms of the [MIT License][licence].

[licence]: https://github.com/drivy/checker_jobs/blob/master/LICENSE.txt
[d-jobs]: https://drivy.engineering/jobs/
[gh-sidekiq]: https://github.com/mperham/sidekiq
