class Rpmbuild::Rpm
  attr_reader :rpm, :spec_file, :macros, :version, :release

  def initialize(spec_file)
    unless File.readable?(spec_file)
      raise ArgumentError, "Could not open file for reading -- #{spec_file}" 
    end
    
    @macros = Rpmbuild::RpmMacroList.new
    @spec_file = spec_file

    parse_spec
  end

  def parse_spec
    content = File.read(@spec_file)
    version_pattern = /Version:([^-~\/\n#]+)/
    release_pattern = /Release:([^-~\/\n#]+)/

    get_tag = lambda do |string, field|
      string.match(/#{field}:([^-~\/\n#]+)/).captures[0].strip
    end

    begin
      @version = get_tag.call(content, "Version")
      @release = get_tag.call(content, "Release")
    rescue
      raise RpmSpecError, "Could not parse spec file"
    end
  end

  def build
    # ...
    parse_rpm
    verify
    sign
    self
  end

  private
  def check_spec
  end

  def parse_rpm
    # Output of the 'rpmbuild' command 
    # check it for lines 'Wrote: '
    # If more than one such line: raise!
  end
  
  def verify
  end

  def sign
    # popen_exec!(command: RPM_SIGN_SCRIPT, arguments: [target])
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
