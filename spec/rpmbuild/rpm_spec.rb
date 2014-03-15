require 'spec_helper'
require 'tempfile'

describe Rpmbuild::Rpm do
  before :each do
    FileUtils.rm Dir.glob(File.join(target_dir, '*'))
  end

  let(:builder)    { Rpmbuild::Rpm.new(spec) }
  let(:test_dir)   { File.expand_path('../test_data', __FILE__) }
  let(:target_dir) { File.join(test_dir, 'RPMS', 'noarch') }
  let(:target)     { File.join(target_dir, 'test-1-r1.noarch.rpm') }
  let(:spec)       { File.join(test_dir, 'test.spec') }


  subject { builder }

  its(:macros) { should be_an_instance_of(Rpmbuild::RpmMacroList) }
  its(:spec_file) { should eq(spec) }
  its(:version) { should eq('1') }
  its(:release) { should eq('r1') }

  describe '.new' do
    it 'expects a readable file' do
      expect { Rpmbuild::Rpm.new('/non/existing/file') }.
        to raise_error(ArgumentError, 'Could not open file for reading -- /non/existing/file')
    end
  end

  describe '#build' do
    it 'produces a new rpm' do
      expect { builder.build }.to change { File.exists?(target) }.to(true)
    end

    it 'sets the rpm path' do
      expect { builder.build }.to change { builder.rpm }.to(target)
    end

    it 'returns the rpm path' do
      expect(builder.build).to eq(target)
    end

    it 'raises if the build failed' do
      builder.macros.add(error_macro: '1')
      expect { builder.build }.to raise_error(ShellCmdError, 'Command failed')
    end

    it 'honors the defined macros' do
      named_target = File.join(target_dir, 'test_with_macro-1-r1.noarch.rpm')
      builder.macros.add(name_macro: '1')
      builder.build
      expect(builder.rpm).to eq(named_target)
    end
  end

  describe '#built?' do
    it 'is set to true if the rpmbuild succeeds' do
      expect { builder.build }.to change { builder.built? }.to(true)
    end 
  end

  describe '#sign', :sign do
    # These tests use a GPG keyring located in spec/rpmbuild/test_data/.gnupg
    # This allows the sign tests to pass on other RPM build systems

    it 'raises if the rpm is not built' do
      expect { builder.sign('123456') }.
        to raise_error(RpmSignError, 'The RPM is not built yet.')
    end

    it 'signs the RPM' do
      # GPG information is read from $HOME/.gnupg
      ENV['HOME'] = File.expand_path('test_data', File.dirname(__FILE__))

      check_unsigned = lambda do
        ShellCmd.new('rpm', '-K', target).execute.output.match(/ pgp /).nil?
      end

      builder.build
      expect { builder.sign('123456') }.
        to change { check_unsigned.call }.to(false)
    end

    it 'returns the RPM' do
      builder.build
      expect(builder.sign('123456')).to be_an_instance_of(Rpmbuild::Rpm)
    end
  end

end
