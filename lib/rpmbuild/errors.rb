# Public
# Raised if the rpmbuild command somehow failed
RpmBuildError = Class.new(StandardError)

# Public
# Raised if the spec file is invalid
RpmSpecError = Class.new(StandardError)

