# Stub the default directories
%define _topdir       %(pwd)/test_data
%define _builddir     %{_topdir}/BUILD
%define _buildrootdir %{_topdir}/BUILDROOT
%define _rpmdir       %{_topdir}/RPMS
%define _sourcedir    %{_topdir}/SOURCES
%define _srcrpmdir    %{_topdir}/SRPMS

%(%{__mkdir} -p %{_builddir} %{_rpmdir})

# The macro in the Name will change it if defined
# Handy for testing if macros are actually being defined
Name: test%{?name_macro:_with_name_macro}
Group: no_group
Version: 1
Release: 1
Summary: Test RPM for RSpec tests
License: no_license
BuildArch: noarch

%description
No description
%prep
%build
%install

# This line intentionally imitates the output of a successful rpmbuild
# It will test whether the method is getting confused by such outputs
%{?confusion_macro:echo "Wrote: /something/in/the/process"}

# This line intentionally imitates error in the rpmbuild process
# It will test whether the method is correctly reporting the failure
%{?error_macro:exit 1}

%clean
rm -rf %{buildroot}
%files
%changelog

