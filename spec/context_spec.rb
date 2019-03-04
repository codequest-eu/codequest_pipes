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

  describe '#inspect' do
    it 'lists all fields' do
      subject.add(bacon: 'yum', raisins: 'bleh')
      expect(subject.inspect)
        .to match(/bacon=\"yum\", raisins=\"bleh\", @errors=nil/)
    end

    it 'lists nested contexts' do
      subject.add(nested: Pipes::Context.new(foo: 'bar'))
      expect(subject.inspect)
        .to match(/nested=#<Pipes::Context:0x\w+ foo="bar", @errors=nil>,/)
    end
  end # describe '#inspect'

  describe '#add_errors' do
    it 'adds error to error_collector' do
      subject.add_errors(base: 'Error message')
      subject.add_errors(
        base: ['Another error message'],
        user: 'User error message'
      )
      expect(subject.errors).to eq(
        base: ['Error message', 'Another error message'],
        user: ['User error message']
      )
    end
  end # describe '#add_errors'

  describe '#halt' do
    it 'adds error to error collector :base' do
      subject.halt('Some error')
      expect(subject.error).to eq('Some error')
    end
  end # describe '#halt'
end # describe Pipes::Context
