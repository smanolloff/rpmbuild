class Rpmbuild::RpmMacroList < Hash
  def initialize(initial_value = {})
    super
    add(initial_value)
  end

  def add(hash = {})  
    hash.each { |k, v| self[k] = v }
  end
end
