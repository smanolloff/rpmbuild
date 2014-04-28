class Rpmbuild::Rpm
  attr_reader :rpm, :spec_file, :macros, :version, :release

  def initialize(spec_file)
    unless File.readable?(spec_file)
      raise ArgumentError, "Could not open file for reading -- #{spec_file}"
    end

    @macros = Rpmbuild::RpmMacroList.new
    @spec_file = spec_file
    @built = false
    @build_cmd = ShellCmd.new('rpmbuild')
    parse_spec
  end

  def environment
    @build_cmd.environment
  end

  def parse_spec
    content = File.read(spec_file)
    get_tag = lambda do |string, field|
      string.match(/^\s*#{field}:([^-~\/\n#]+)/).captures[0].strip
    end

    begin
      @version = get_tag.call(content, 'Version')
      @release = get_tag.call(content, 'Release')
    rescue
      raise RpmSpecError, 'Could not parse spec file'
    end
  end

  def build(params = {})
    prepare_command
    @build_cmd.execute
    @built = true
    @rpm = parse_rpm_name(@build_cmd.result.output)
  rescue
    raise RpmBuildError, @build_cmd
  end

  def built?
    @built
  end

  def sign(gpg_password)
    raise RpmSignError, 'The RPM is not built yet.' unless built?

    PTY.spawn(@build_cmd.environment, "rpm --addsign #{rpm}") do |pty_out, pty_in, pid|
      pty_in.sync = true
      pty_out.expect(/Enter pass phrase:/, 2) do |result|
        fail RpmSignError, 'Timeout expired (password prompt)' if result.nil?
        pty_in.puts(gpg_password)
      end

      pty_out.expect(/Pass phrase is good/, 2) do |result|
        fail RpmSignError, 'Timeout expired (password confirmation)' if result.nil?
      end

      # Read all remaining output.
      loop { pty_out.readpartial(1024) rescue break }
    end
    self
  rescue Errno::EIO => e
    raise RpmSignError, e.message
  end

private
  def parse_rpm_name(output)
    pattern = /Wrote: (.+)/
    # The first group of the last match
    output.scan(pattern).last.first
  end

  def prepare_command
    unless built?
      @build_cmd.add_arguments('-bb', spec_file, *macros.to_cli_arguments)
    end
  end
end
