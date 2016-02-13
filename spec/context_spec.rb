require 'spec_helper'

describe Pipes::Context do
  let(:ctx) { Pipes::Context.new }

  describe '#add' do
    it 'allows adding new fields' do
      ctx.add(key: 'val')
      expect(ctx.key).to eq('val')
    end

    it 'does not allow rewriting existing fields' do
      ctx.add(key: 'val')
      expect { ctx.add(key: 'other_val') }
        .to raise_error(Pipes::Context::Override)
    end
  end
end # describe Context
