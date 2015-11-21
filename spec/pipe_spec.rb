require 'spec_helper'

# Parent is a dummy test class.
class Parent
  include Pipes::Pipe

  require_ctx :flow

  def self.call(ctx)
    ctx.flow.push(name)
  end
end # class Parent

class Child < Parent; end
class Grandchild < Parent; end
class GrandGrandchild < Parent; end

# BadApple will break.
class BadApple
  include Pipes::Pipe
  def self.call(_ctx)
    fail StandardError
  end
end

# NoMethodPipe will break with NoMethodError.
class NoMethodPipe
  include Pipes::Pipe
end

describe Pipes::Pipe do
  let(:ctx) { Pipes::Context.new(flow: []) }

  subject { pipe.call(ctx) }

  context 'with well-behaved pipes' do
    let(:pipe) { Parent | Child | Grandchild }

    it 'executes the pipe left to right' do
      expect { subject }.to change { ctx.flow }
        .from([]).to %w(Parent Child Grandchild)
    end
  end # context 'with well-behaved pipes'

  context 'when a pipe raises an exception' do
    let(:pipe) { Parent | BadApple | Child }

    it 'raises the exception' do
      expect { pipe.call(ctx) }.to raise_error(StandardError)
    end

    it 'stores the result of execution so far in the context' do
      # rubocop:disable Style/RescueModifier
      expect { pipe.call(ctx) rescue nil }
        .to change { ctx.flow }
        .from([]).to(['Parent'])
      # rubocop:enable Style/RescueModifier
    end
  end # context 'with badly-behaved pipes'

  context 'with pipes created on the fly' do
    let(:dynamic_grandchild) do
      Pipes::Closure.define { |ctx| ctx.flow << 'bacon' }
    end
    let(:pipe) { Parent | dynamic_grandchild | Child }

    it 'behaves as with normal pipes' do
      expect { subject }
        .to change { ctx.flow }
        .from([]).to %w(Parent bacon Child)
    end
  end

  context 'with a class that does not implement the `call` method' do
    let(:pipe) { Parent | Child | NoMethodPipe }

    it 'raises a NoMethodError' do
      expect { subject }.to raise_error(NoMethodError)
    end
  end # context 'with a class that does not implement the call method'

  context 'with combined pipes' do
    let(:first)  { Parent | Child }
    let(:second) { Grandchild | GrandGrandchild }
    let(:pipe)   { first | second }

    it 'behaves as with normal pipes' do
      expect { subject }
        .to change { ctx.flow }
        .from([]).to %w(Parent Child Grandchild GrandGrandchild)
    end

    context 'with broken combination' do
      let(:second) { NoMethodPipe | Grandchild }

      it 'raises error from a broken pipe' do
        expect { subject }.to raise_error NoMethodError
      end
    end # context 'with broken combination'
  end # context 'with combined pipes'
end # describe Pipes::Pipe
