require 'spec_helper'

describe Rpmbuild::RpmMacroList do
  subject(:macro_list) { Rpmbuild::RpmMacroList.new(macro1: 'value1') }

  its(:class) { should be < HashWithIndifferentAccess }

  describe '.new' do
    it 'also accepts more than 1 macro' do
      list = Rpmbuild::RpmMacroList.new(macro1: 'value1', macro2: 'value2')
      expect(list).to eq( { 'macro1' => 'value1', 'macro2' => 'value2' } )
    end
  end

  describe '#add' do
    it 'adds a new macro' do
      empty_list = Rpmbuild::RpmMacroList.new

      expect { empty_list.add(macro1: 'value1') }.
        to change { empty_list }.to( { 'macro1' => 'value1' } )
    end

    it 'also accepts more than 1 macro' do
      empty_list = Rpmbuild::RpmMacroList.new

      expect { empty_list.add(macro1: 'value1', macro2: 'value2') }.
        to change { empty_list }.
        to( { 'macro1' => 'value1', 'macro2' => 'value2' } )
    end
  end


  describe '#to_cli_arguments' do
    it 'converts macros to a list of arguments for rpmbuild' do
      expect(macro_list.to_cli_arguments).to eq(['--define', 'macro1 value1'])
    end
  end
end