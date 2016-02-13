# Pipes [![Build Status](https://travis-ci.org/codequest-eu/codequest_pipes.svg?branch=master)](https://travis-ci.org/codequest-eu/codequest_pipes) [![codebeat badge](https://codebeat.co/badges/73f1bb7f-516f-4fc5-b241-daea42c7badd)](https://codebeat.co/projects/codequest_pipes-master-ab1a7c5f-ad5f-425a-a0f0-e56e13a04876)

Pipes provide a Unix-like way to chain business objects (interactors) in Ruby.

## Installation

To start using Pipes, add the library to your Gemfile. This project is currently
not available on RubyGems.

```ruby
gem "codequest_pipes", github: "codequest-eu/codequest_pipes"
```

## High-level usage example

```ruby
FLOW = Projects::Match         | # NOTE: each of the elements must inherit from
       Projects::Validate      | # Pipes::Pipe!
       Projects::UpdatePayment |
       Projects::SaveWithReport
context = Pipes::Context.new(project: p)
FLOW.call(context)
```

## Pipe

Pipes provide a way to describe business transactions in a stateless
and reusable way. Let's create a few pipes from plain Ruby classes.

```ruby
class PaymentPipe < Pipes::Pipe
  require_context :user        # flow will fail if precondition not met
  provide_context :transaction # flow will fail if postcondition not met

  def call
    result = PaymentService.create_transaction(user)
    add(transaction: result.transaction)
  end
end
```

Note how we've only had to implement the `call` method for the magic to start happening. When calling these objects you'd be using the class method `call` instead and passing a `Pipes::Context` objects to it. All unknown messages (like `user`) in two examples above are passed to the `context` which is an instance variable of every object inheriting from `Pipes::Pipe`.

## Context

Each Pipe requires an instance `Pipes::Context` to be passed on `.call` invokation. It provides append-only data container for Pipes: you can add data to a context at any time using the `add` method but the same call will raise an error if you try to modify an existing key.

Made with ❤️ by [code quest](http://www.codequest.com)









