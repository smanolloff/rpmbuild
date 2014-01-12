# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rpmbuild/version'

Gem::Specification.new do |spec|
  spec.name          = "rpmbuild"
  spec.version       = Rpmbuild::VERSION
  spec.authors       = ["Simeon Manolov"]
  spec.email         = ["s.manolloff@gmail.com"]
  spec.summary       = %q{Build RPMs with ease}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  soec.add_runtime_dependency "shell_cmd"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
