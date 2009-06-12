#!/usr/bin/perl -w

#
# Import an entity metadata fragment file.
#
# This utility is intended for use immediately before checking in a new entity fragment,
# or prior to checking in major changes such as to embedded trust certificates.
#
# The fragment is indicated by a numeric parameter, e.g. 999 would indicate uk000999.xml
#
#		./check_entity 123
#

system("java -cp ../bin:../lib/joda-time-1.6.jar -Djava.endorsed.dirs=../endorsed org.apache.xalan.xslt.Process -IN ../entities/import.xml -OUT ../entities/imported.xml -XSL import.xsl");
