require 'spec_helper'

describe Pipes::Context do
  describe '#add' do
    it 'allows adding new fields' do
      subject.add(key: 'val')
      expect(subject.key).to eq('val')
    end

    it 'does not allow rewriting existing fields' do
      subject.add(key: 'val')
      expect { subject.add(key: 'other_val') }
        .to raise_error(Pipes::Context::Override)
    end
  end # describe '#add'

  describe '#to_s' do
    it 'lists all fields' do
      subject.add(bacon: 'yum', raisins: 'bleh')
      expect(subject.inspect)
        .to match(/bacon=\"yum\", raisins=\"bleh\", @error=nil/)
    end
  end # describe '#to_s'
end # describe Pipes::Context
