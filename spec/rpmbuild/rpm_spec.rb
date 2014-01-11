require 'spec_helper'
require 'tempfile'

describe Rpmbuild::Rpm do
  before :each do
    FileUtils.rm Dir.glob(File.join(target_dir, '*'))
  end

  let(:builder)    { Rpmbuild::Rpm.new(spec) }
  let(:test_dir)   { File.join(File.dirname(__FILE__), 'test_data') }
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
        to raise_error(ArgumentError, "Could not open file for reading -- /non/existing/file")
    end
  end

  describe '#build' do
    it 'produces a new rpm' do
      expect { builder.build }.to change { File.exists?(target) }.to(true)
    end

    it 'sets the rpm path' do
      expect { builder.build }.to change { builder.rpm }.to(target)
    end

    it 'raises if the rpm is not created' do
      rpm_path = '/wrong/rpm/path'
      CommandResult.any_instance.stub(:output => "Wrote: #{rpm_path}")

      expect { builder.build }.
        to raise_error(RpmBuildError, "RPM build succeeded, but did not produce expected RPM at #{rpm_path}")
    end

    it 'returns the result of #built?' do
      expect(builder).to receive(:built?).with(no_args).and_return(:baboon)
      expect(builder.build).to eq(:baboon)
    end

    context 'when the target already exists' do
      before :each do
        FileUtils.touch(target)
      end

      it 'raises unless forced to overwite' do
        expect { builder.build(force: true) }.not_to raise_error
        expect { builder.build }.
          to raise_error(RpmBuildError, "Target RPM already exists at #{target}")
      end
    end

    it 'honors the defined macros' do
      named_target = File.join(target_dir, 'test_with_macro-1-r1.noarch.rpm')
      builder.macros.add(name_macro: '1')
      builder.build
      expect(builder.rpm).to eq(named_target)
    end
  end

  describe '#rebuild' do
    it 'calls #build(force: true)' do
      expect(builder).to receive(:build).with(force: true).and_return(:coala)
      builder.rebuild
    end
  end

  describe '#built?' do
    it 'returns true if the rpmbuild succeeded' do
      expect { builder.build }.to change { builder.built? }.to(true)
    end 

    it 'returns false if the rpmbuild failed' do
      CommandResult.any_instance.stub(:success? => false)
      expect { builder.build }.not_to change { builder.built? }
    end

    context 'after calling #rebuild' do
      it 'is reinitialized' do
        # Set the #built? initially to true
        builder.build
        CommandResult.any_instance.stub(:success? => false)
        expect { builder.rebuild }.to change { builder.built? }.to(false)
      end
    end

    context 'when the target already exists and the build fails' do
      before :each do
        FileUtils.touch(target)
        CommandResult.any_instance.stub(:success? => false)
        builder.build
      end

      it 'returns false' do
        expect(builder.built?).to eq(false)
      end
    end
  end

  describe '#sign' do
    it 'raises if the rpm is not built' do
      expect { builder.sign }.
        to raise_error(RpmSignError, "The RPM is not built yet.")
    end

    it 'signs the RPM' do
      builder.build
      check = ShellCommand.new('rpm', '-K', target)

      expect { builder.sign }.
        to change { check.execute.result.chomp }.
        from("#{target}: sha1 md5 OK").
        to("#{target}: sha1 md5 gpg OK")
    end
  end

end