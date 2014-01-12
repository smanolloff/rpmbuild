# Public
# Raised when the spec file is invalid
RpmSpecError = Class.new(StandardError)

# Public
# Raised when the rpmbuild fails
RpmBuildError = Class.new(ShellCmdError)

# Public
# Raised when the rpm sign fails
RpmSignError = Class.new(StandardError)
