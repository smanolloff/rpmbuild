require 'spec_helper'
require 'rpmbuild/rpm_macro_list'

describe Rpmbuild::RpmMacroList do
  let(:raw_hash)  { { macro1: 'value1', macro2: 'value2' } }

  subject(:empty_list) { Rpmbuild::RpmMacroList.new }

  it { should respond_to(:add) }
  its(:class) { should be < Hash }

  it 'can be initialized with a list of macros' do
    list = Rpmbuild::RpmMacroList.new(raw_hash)
    expect(list).to eq(raw_hash)
  end

  it 'allows to add new macros' do
    expect { empty_list.add(raw_hash) }.
      to change { empty_list }.from({}).to(raw_hash)
  end
end