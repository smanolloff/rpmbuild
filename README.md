# Rpmbuild

Build and sign RPM packages

## Installation

Add this line to your application's Gemfile:

    gem 'rpmbuild'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rpmbuild

## Usage

    require 'rpmbuild'

    builder = Rpmbuild::Rpm.new('/path/to/rpm.spec')
    builder.macros.add(macro_name: 'macro_value')
    builder.build
    # => "/home/user/rpmbuild/RPMS/noarch/rpm-1-r1.noarch.rpm"

    builder.sign
    # => #<Rpmbuild::Rpm:0x00000004e463b8>


## Contributing

1. Fork it ( http://github.com/<my-github-username>/rpmbuild/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
