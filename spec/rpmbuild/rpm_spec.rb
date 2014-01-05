require 'spec_helper'
require 'tempfile'

describe Rpmbuild::Rpm do
  before :all do
    @file = Tempfile.new('spec_file')
  end

  after :all do
    @file.delete
  end

  let(:spec) { @file.path }
  let(:rpm)  { Rpmbuild::Rpm.new(spec) }

  subject { rpm }

  it { should respond_to(:build) }
  its(:macros) { should be_an Rpmbuild::RpmMacroList }

  it 'sets the path to the rpm' do
    pending 'stub the ENV[] variables and then test the destination'
  end

  it 'verifies the spec file' do
    allow(File).to receive(:file?).with(spec).and_return(false)

    expect { Rpmbuild::Rpm.new(spec) }.
      to raise_error(RpmSpecError, "Invalid spec file: #{spec}")
  end

  it 'verifies the created rpm' do
    # TODO: mock ShellCommand's instances to always return the same
    # string when executed (with a known 'Wrote: ...' line, i.e. known rpm)

    expect(File).to receive(:file?).with(rpm.rpm).and_return(false)
    expect(File).to receive(:file?).with(spec).and_return(true)

    expect { rpm.build }.
      to raise_error(RpmBuildError, "RPM build succeeded, but did not produce expected RPM at #{rpm.rpm}")
  end

  it 'signs the rpm' do
    pending 'somehow check if RPM is signed after build'
  end
end