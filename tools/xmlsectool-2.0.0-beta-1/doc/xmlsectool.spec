%define unzip /usr/bin/unzip
%define scriptname xmltool
Summary: Java command line tool for checking and verifying XML documents
Name: xmlsectool
Version: 1.2.0
Release: 1
Epoch: 0
License: Apache License 2.0
Group: System Environment/Libraries
Source0: http://www.shibboleth.net/downloads/tools/%{name}/%{version}/%{name}-%{version}-bin.zip
Patch0: xmlsectool.patch
URL: https://wiki.shibboleth.net/confluence/display/SHIB2/XmlSecTool
Requires: java
BuildRequires: unzip
BuildArch: noarch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%(id -u -n)

%description
The xmlsectool is a Java command line tool that can download, check
well-formedness, schema validity, and signature of an XML document.
It can also create enveloped signatures of an XML document.

%prep
%{__rm} -rf %{name}-%{version}
%{unzip} -q $RPM_SOURCE_DIR/%{name}-%{version}-bin.zip
cd %{name}-%{version}

%patch -p1

%install
[ "$RPM_BUILD_ROOT" != "/" ] && %{__rm} -rf $RPM_BUILD_ROOT

install -d %{buildroot}%{_bindir}
install $RPM_BUILD_DIR/%{name}-%{version}/%{scriptname}.sh %{buildroot}%{_bindir}/%{scriptname}

install -d %{buildroot}%{_javadir}/%{name}/endorsed
install -m644 $RPM_BUILD_DIR/%{name}-%{version}/lib/*.jar %{buildroot}%{_javadir}/%{name}
install -m644 $RPM_BUILD_DIR/%{name}-%{version}/lib/endorsed/*.jar %{buildroot}%{_javadir}/%{name}/endorsed

install -d %{buildroot}%{_docdir}/%{name}
install -m644 $RPM_BUILD_DIR/%{name}-%{version}/doc/* %{buildroot}%{_docdir}/%{name}

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && %{__rm} -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, -)
%attr(755,root,root) %{_bindir}/%{scriptname}
%doc %{_docdir}/%{name}/*
%dir %{_javadir}/%{name}
%{_javadir}/%{name}/*

%changelog
* Mon Mar 04 2013 Ian Young <ian@iay.org.uk> 1.2.0-1
- Import into xmlsectool package, update to latest version.

* Wed Apr 06 2011 Peter Schober <peter.schober@univie.ac.at> 1.1.3-2
- Remove version numbers from patch file and patch with -p1

* Wed Apr 06 2011 Peter Schober <peter.schober@univie.ac.at> 1.1.3-1
- Update to upstream version 1.1.3

* Tue Apr 05 2011 Peter Schober <peter.schober@univie.ac.at> 1.1.2-2
- Changed Source URL (downloads moved to shibboleth.net)

* Tue Apr 05 2011 Peter Schober <peter.schober@univie.ac.at> 1.1.2-1
- Update to upstream version 1.1.2
- Changed scriptname
- Changed URL (Wiki moved to shibboleth.net)

* Fri Feb 18 2011 Peter Schober <peter.schober@univie.ac.at> 1.1.1-2
- Move jar files from lib/ and patch shell wrapper accordingly,
  use _javadir macro (instead of _datadir/java).

* Fri Feb 18 2011 Peter Schober <peter.schober@univie.ac.at> 1.1.1-1
- Initial package
