require 'spec_helper'
require 'tempfile'

describe Rpmbuild::Rpm do
  before :each do
    # Important, as rpmbuild's build path is 
    # defined as relative to the current path.
    Dir.chdir(test_dir)
    FileUtils.rm_f Dir.glob(File.join(target_dir, '*'))
  end

  let(:builder)    { Rpmbuild::Rpm.new(spec) }
  let(:test_dir)   { File.join(File.dirname(__FILE__), 'test_data') }
  let(:target_dir) { File.join(test_dir, 'RPMS', 'noarch') }
  let(:target)     { File.join(target_dir, 'test-1-1.noarch.rpm') }
  let(:spec)       { File.join(test_dir, 'test.spec') }


  subject { builder }

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
      expect { builder.build }.
        to change { File.exists?(target) }.from(false).to(true)
    end

    it 'sets the rpm path' do
      expect { builder.build }.to change { builder.rpm }.to(target)
    end

    it 'raises if the rpm is not created' do
      rpm_path = '/path/to/rpm'
      CommandResult.any_instance.stub(
        :success? => true, 
        :output => "Wrote: #{rpm_path}"
      )

      expect { builder.build }.
        to raise_error(RpmBuildError, "RPM build succeeded, but did not produce expected RPM at #{builder.rpm}")
    end
  end

  describe '#built?' do
    pending
  end

  it 'signs the rpm' do
    pending 'somehow check if RPM is signed after build'
  end
end