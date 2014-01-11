require 'spec_helper'
require 'tempfile'

describe Rpmbuild::Rpm do
  let(:data_folder) { File.join(File.dirname(__FILE__), 'test_data') }
  let(:spec) { File.join(data_folder, 'rpm_example.spec') }
  let(:rpm) { Rpmbuild::Rpm.new(spec) }


  subject { rpm }

  its(:macros) { should be_an_instance_of(Rpmbuild::RpmMacroList) }
  its(:spec_file) { should eq(spec) }

  describe '.new' do
    it 'expects a readable file' do
      expect { Rpmbuild::Rpm.new('/non/existing/file') }.
        to raise_error(Errno::ENOENT)
    end
  end

  describe '#build' do
    it 'produces a new rpm' do
      expect { rpm.build }.to change { File.exists? }
    end

    it 'sets the rpm path' do
      rpm_path = '/path/to/rpm'
      CommandResult.any_instance.stub(:success? => true, :output => "Wrote: #{rpm_path}")
      expect(File).to receive(:file?).with(rpm_path).and_return(true)

      expect { rpm.build }.to change(rpm.rpm).to(rpm_path)
    end

    it 'raises if the rpm is not created' do
      rpm_path = '/path/to/rpm'
      CommandResult.any_instance.stub(:success? => true, :output => "Wrote: #{rpm_path}")

      expect { rpm.build }.
        to raise_error(RpmBuildError, "RPM build succeeded, but did not produce expected RPM at #{rpm.rpm}")
    end
  end

  describe '#built?' do
    pending
  end

  it 'signs the rpm' do
    pending 'somehow check if RPM is signed after build'
  end
end