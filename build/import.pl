#!/usr/bin/perl -w

use Xalan;

#
# Import an entity metadata fragment file.
#
# This utility is intended for use immediately before checking in a new entity fragment,
# or prior to checking in major changes such as to embedded trust certificates.
#
# The fragment is always taken from entities/import.xml, and the output is always placed
# in entities/imported.xml.
#

system(xalanCall . " -IN ../entities/import.xml -OUT ../entities/imported.xml -XSL import.xsl");
