# Pipes

Pipes provide a Unix-like way to chain business objects (interactors) in Ruby.

[![Build Status](https://travis-ci.org/codequest-eu/codequest_pipes.svg?branch=master)](https://travis-ci.org/codequest-eu/codequest_pipes)

## Installation

To start using Pipes, add the library to your Gemfile. This project is currently
not available on RubyGems.

```
gem "codequest_pipes", git: "codequest-eu/codequest_pipes"
```

## Pipe

Pipes provide a way to describe business transactions in a stateless
and reusable way. Let's create a few pipes from plain Ruby classes.

```
class PaymentPipe
  include Pipes::Pipe

  def self.call(context)
    result = PaymentService.create_transaction(context.user)
    context.user.transaction_id = result.transaction_id
  end
end
```

```
class SaveUserPipe
  include Pipes::Pipe

  def self.call(context)
    context.user.save!
  end
end
```

## Context

Each Pipe requires a `Context` to run on. It provides data for pipes as well as an
interface for handling errors and lifecycle events  using `on_start`, `on_success`,
and `on_error` callbacks triggered for each `Pipe` in a given flow.
You can add data to a context at any time using the `add` method,
but it will raise an error if you try to modify an existing key.

```
class PaymentContext < Pipes::Context
  def on_error(_klass, _method, exception)
    bugsnag.notify(exception) if exception == PaymentService::Error
    false
  end
end
```

## Sample flow with Pipes

```
context = PaymentContext.new(user: u)
(PaymentPipe | SaveUserPipe).call(context)
```

# Contributing & License

TODO

Made with ❤️ by [code quest](http://www.codequest.com)









