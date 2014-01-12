class Rpmbuild::RpmMacroList < HashWithIndifferentAccess
  def initialize(initial_value = {})
    super
    add(initial_value)
  end

  def add(hash = {})  
    hash.each { |k, v| self[k.to_s] = v.to_s }
  end

  def to_cli_arguments
    self.map { |name, value| ["--define", "#{name} #{value}"] }.flatten
  end
end
