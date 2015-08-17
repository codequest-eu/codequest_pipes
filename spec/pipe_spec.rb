require 'spec_helper'

# Parent is a dummy test class.
class Parent
  include Pipes::Pipe
  def self.call(ctx)
    ctx.flow.push('parent')
  end
end

# Parent is a dummy test class.
class Child
  include Pipes::Pipe
  def self.call(ctx)
    ctx.flow.push('child')
  end
end

# BadApple will break.
class BadApple
  include Pipes::Pipe
  def self.call(_ctx)
    fail StandardError
  end
end

# Grandchild is a dummy test class.
class Grandchild
  include Pipes::Pipe
  def self.call(ctx)
    ctx.flow.push('grandchild')
  end
end

# NoMethodPipe will break with NoMethodError.
class NoMethodPipe
  include Pipes::Pipe
end

# TrackingContext is a context that tracks execution of subsequent pipe
# elements.
class TrackingContext < Pipes::Context
  def on_start(klass, method)
    execution.push("#{klass.name}.#{method} started")
  end

  def on_success(klass, method)
    execution.push("#{klass.name}.#{method} succeeded")
  end
end

# ErrorTrackingContext is a TrackingContext which additionally captures errors.
# You explicitly can tell it to fail on error or not.
class ErrorTrackingContext < TrackingContext
  def initialize(should_fail = true)
    @should_fail = should_fail
  end

  def on_error(klass, method, exception)
    execution.push("#{klass}.#{method} failed with #{exception.class.name}")
    !@should_fail
  end
end

describe Pipes::Pipe do
  context 'with well-behaved pipes' do
    before(:each) do
      @pipe = Parent | Child | Grandchild
      @ctx = TrackingContext.new(flow: [], execution: [])
    end

    it 'executes the pipe left to right' do
      @pipe.call(@ctx)
      expect(@ctx.flow).to eq(%w(parent child grandchild))
    end

    it 'does not allow instantiating classes including Pipes::Pipe' do
      expect { Parent.new }.to raise_error(Pipes::InstanceError)
    end

    it 'executes on_start and on_success callbacks' do
      @pipe.call(@ctx)
      expect(@ctx.execution).to eq([
        'Parent.call started',
        'Parent.call succeeded',
        'Child.call started',
        'Child.call succeeded',
        'Grandchild.call started',
        'Grandchild.call succeeded'
      ])
    end
  end  # context 'with well-behaved pipes'

  context 'with badly-behaved pipes' do
    it 'records and breaks on an exception' do
      pipe = Parent | BadApple | Child
      ctx = ErrorTrackingContext.new(true)  # should fail on error
      ctx.add(flow: [], execution: [])
      expect { pipe.call(ctx) }.to raise_error(StandardError)
      expect(ctx.flow).to eq(%w(parent))
      expect(ctx.execution).to eq([
        'Parent.call started',
        'Parent.call succeeded',
        'BadApple.call started',
        'BadApple.call failed with StandardError'
      ])
    end

    it 'records but continues on an exception' do
      pipe = Parent | BadApple | Child
      ctx = ErrorTrackingContext.new(false)  # should continue on error
      ctx.add(flow: [], execution: [])
      pipe.call(ctx)
      expect(ctx.flow).to eq(%w(parent child))
      expect(ctx.execution).to eq([
        'Parent.call started',
        'Parent.call succeeded',
        'BadApple.call started',
        'BadApple.call failed with StandardError',
        'Child.call started',
        'Child.call succeeded'
      ])
    end
  end  # context 'with badly-behaved pipes'

  context 'with a relaxed calling convention' do
    it 'allows hash initialization and direct reading of result' do
      pipe = Parent | Child | Grandchild
      result = pipe.call(flow: [])
      expect(result.flow).to eq(%w(parent child grandchild))
    end
  end

  context 'with pipes created on the fly' do
    it 'behaves as with normal pipes' do
      dynamic_grandchild = Pipes::Closure.define(:call) do |ctx|
        ctx.flow << 'dynamic_grandchild'
      end
      pipe = Parent | dynamic_grandchild | Child
      result = pipe.call(flow: [])
      expect(result.flow).to eq(%w(parent dynamic_grandchild child))
    end
  end

  context 'with a class that does not implement the `call` method' do
    it 'raises a NoMethodError' do
      pipe = Parent | Child | NoMethodPipe
      expect { pipe.call(flow: []) }.to raise_error(NoMethodError)
    end
  end  # context 'with a class that does not implement the call method'
end  # describe Pipes::Pipe
