# require 'spec_helper'

require 'rpmbuild/rpm'

describe Rpmbuild::Rpm do
  subject(:rpm) { Rpmbuild::Rpm.new }

  let(:macros)  { { macro1: 'value1', macro2: 'value2', macro3: 'value3' } }

  # Note: 
  # popen_exec! is a method of the Rpm class, 
  # because the module was 'include'd in there.
  # So, expect(rpm).to_receive(:popen_exec!) is correct.

  it { should respond_to(:add_build_macros) }
  it { should respond_to(:build) }
  it { should respond_to(:verify) }
  it { should respond_to(:sign) }
  it { should respond_to(:popen_exec!) }

  it 'allows user-defined macros' do
    expect(rpm.add_build_macros(macros)).to
      change(rpm.build_macros).from({}).to(macros)
  end

  it 'runs rpmbuild with all the macros' do
    rpm.add_build_macros(macros)
    expected_args = [
      '-ba',
      '--define macro1 value1',
      '--define macro2 value2',
      '--define macro3 value3',
      CUSTOMIZATION_SPEC
    ]

    expect(rpm).to receive(:popen_exec!).
      with(command: 'rpmbuild', arguments: expected_arguments)

    rpm.sign!
  end

  it 'verifies the rpm' do
    FileUtils.stub(:file?).with(rpm.target) { false }
    expect(rpm.verify!).
      to raise_error(RpmBuildError, "RPM build succeeded, but did not produce expected RPM at #{target}")
  end



  it 'runs the sign_rpm script' do
    expect(rpm).to receive(:popen_exec!).
      with(command: RPM_SIGN_SCRIPT, arguments: [rpm.target])
    rpm.sign!
  end
end