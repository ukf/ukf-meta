#!/usr/bin/perl -w

#
# Import an entity metadata fragment file.
#
# This utility is intended for use immediately before checking in a new entity fragment,
# or prior to checking in major changes such as to embedded trust certificates.
#
# The fragment is always taken from entities/import.xml, and the output is always placed
# in entities/imported.xml.
#

system("java -cp ../bin:../lib/joda-time-1.6.jar -Djava.endorsed.dirs=../tools/xalan/endorsed org.apache.xalan.xslt.Process -IN ../entities/import.xml -OUT ../entities/imported.xml -XSL import.xsl");
