module Rpmbuild
  class Rpm
    # NOTE: @macros is a RpmMacroList instance
    #       Do not monkey-patch anything, just 
    #       define the 'add' method:
    #
    # class RpmMacroList < Hash
    #   def add(hash = {})  
    #     hash.each { |k, v| self[k] = v }
    #   end
    # end

    attr_reader :target, :macros

    def initialize(spec_file)
      @macros = RpmMacroList.new
      # TODO: check if spec exists
    end

    def prepare_files
      # Logos, mainly
    end

    def build
      # ...
      verify
      sign
      self
    end

  private
    def verify
    end

    def sign
      popen_exec!(command: RPM_SIGN_SCRIPT, arguments: [target])
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
end
