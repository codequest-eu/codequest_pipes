require 'spec_helper'
require 'rspec/matchers/fail_matchers'
require 'codequest_pipes/rspec'

RSpec.configure do |config|
  config.include RSpec::Matchers::FailMatchers
end

describe 'expect(...).to match(pipe_context(expected))' do
  let(:ctx) { Pipes::Context.new(foo: 'foo', bar: {}, baz: 1) }
  let(:expected) { nil }

  shared_examples_for 'fails_with_message' do |message|
    it 'fails' do
      expected_message =
        message || /expected #<Pipes::Context:.+ @error=nil> to match/
      expect { expect(ctx).to match(pipe_context(expected)) }
        .to fail_with(expected_message)
    end
  end # shared_examples_for 'fails'

  context 'when any key is missing' do
    let(:expected) { {foo: 'foo', bacon: {}} }
    it_behaves_like 'fails_with_message'
  end # context 'when any key is missing'

  context 'when actual is not Pipes::Context' do
    let(:ctx) { 'bacon' }

    it_behaves_like 'fails_with_message', /expected "bacon" to match/
  end # context 'when expected is not Pipes::Context'

  context 'when any key matcher fails' do
    let(:expected) { {foo: 'foo', bar: {}, baz: 'bacon'} }

    it_behaves_like 'fails_with_message'
  end # context 'when any key matcher fails'

  context 'when any value not equal' do
    let(:expected) { {foo: 'foo', bar: {}, baz: 2} }

    it_behaves_like 'fails_with_message'
  end

  context 'when all keys match' do
    let(:expected) { {foo: 'foo', bar: {}, baz: 1} }
    it 'succeeds' do
      expect(ctx).to match(pipe_context(expected))
    end
  end # context 'when all keys match'
end # describe 'pipe_context'
