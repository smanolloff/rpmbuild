class Rpmbuild::Rpm
  attr_reader :rpm, :spec_file, :macros, :version, :release

  def initialize(spec_file)
    unless File.readable?(spec_file)
      raise ArgumentError, "Could not open file for reading -- #{spec_file}" 
    end
    
    @macros = Rpmbuild::RpmMacroList.new
    @spec_file = spec_file
    @built = false
    parse_spec
  end

  def parse_spec
    content = File.read(spec_file)
    get_tag = lambda do |string, field|
      string.match(/^\s*#{field}:([^-~\/\n#]+)/).captures[0].strip
    end

    begin
      @version = get_tag.call(content, "Version")
      @release = get_tag.call(content, "Release")
    rescue
      raise RpmSpecError, "Could not parse spec file"
    end
  end

  def build(params = {})
    cmd = ShellCmd.new(
      'rpmbuild', 
      '-bb', 
      spec_file, 
      *macros.to_cli_arguments
    )

    begin
      cmd.execute
      @rpm = parse_rpm_name(cmd.result.output)
    rescue
      # puts cmd.result.report
      raise RpmBuildError, cmd
    end

    @built = true
    rpm
  end

  def built?
    @built
  end

  def sign(gpg_password)
    raise RpmSignError, "The RPM is not built yet." unless built?

    PTY.spawn("rpm --addsign #{rpm}") do |pty_out, pty_in, pid|
      pty_in.sync = true
      pty_out.expect(/Enter pass phrase:/, 2) do |result|
        if result.nil?
          raise RpmSignError, "Timeout expired (password prompt)"
        end
        pty_in.puts(gpg_password)
      end

      pty_out.expect(/Pass phrase is good/, 2) do |result|
        if result.nil?
          raise RpmSignError, "Timeout expired (password confirmation)"
        end
      end
      loop { pty_out.readpartial(1024) rescue break }
    end
  end

  private
  
  def parse_rpm_name(output)
    pattern = /Wrote: (.+)/
    # The first group of the last match
    output.scan(pattern).last.first
  end




  # def rpm_location(time = Time.now)
  #   if self.new_record?
  #     "#{RPMS_DIR}/noarch/circle_customization_#{common_name(time)}-#{full_release}.noarch.rpm"
  #   else
  #     "#{RPMS_DIR}/noarch/#{self.rpm}"
  #   end
  # end

  # def common_name(time = @timestamp)
  #   "#{country_abbr}_#{customer}-#{version(time)}"
  # end

  # def full_release
  #   @timestamp ||= Time.now 
  #   r = release
  #   t = @timestamp.strftime("%H.%M")
  #   el = centos_version.to_str[/\d+/]

  #   return "#{t}_el#{el}_r#{r}"
  # end


  # def self.parse_template_release
  #   spec_file = SpecFile.new
  #   return spec_file.release

  #   # template_regexp = /^Version: {::VERSION::}.+^Release: {::RELEASE::}_r(\d+)/m
  #   # raise MissingSpecTemplateError, CUSTO_TEMPLATE unless File.file?(CUSTO_TEMPLATE)
  #   # raise InvalidSpecTemplateError, CUSTO_TEMPLATE unless template_regexp.match(File.read(CUSTO_TEMPLATE))
  #   # return $1.to_i
  # end


  # def version(time)
  #   time.strftime("%Y.%m.%d")
  # end
end
