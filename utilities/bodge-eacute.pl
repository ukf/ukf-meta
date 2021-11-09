#!/usr/bin/perl -w -p -i
#
# É is changed to HTML character entity reference &Eacute;
#
# An awful bodge to fix output of IdPInfoList. Our instance of
# PMwiki encodes pages in windows-1252 (single byte character encoding),
# and IdPInfoList includes a file encoded in UTF-8. All is well until
# we have a 2-byte character in GÉANT.
# 
binmode(STDOUT, ":encoding(UTF-8)");
s/É/&Eacute;/g;
s/é/&eacute;/g;
s/ü/&uuml;/g;