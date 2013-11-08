#!/usr/bin/perl -w

#
# Apply a given one-off change to the input fragment file.
#

while (<>) {

	s {(\s)(?=shibboleth-metadata-1\.0\.xsd)}        {$1..\/xml\/};
	s {(\s)(?=sstc-saml-schema-assertion-2\.0\.xsd)} {$1..\/xml\/};
	s {(\s)(?=sstc-saml-schema-metadata-2\.0\.xsd)}  {$1..\/xml\/};
	s {(\s)(?=uk-fed-label\.xsd)}                    {$1..\/xml\/};
	s {(\s)(?=xenc-schema\.xsd)}                     {$1..\/xml\/};
	s {(\s)(?=xml\.xsd)}                             {$1..\/xml\/};
	s {(\s)(?=xmldsig-core-schema\.xsd)}             {$1..\/xml\/};
	
	print $_;
}

# end
