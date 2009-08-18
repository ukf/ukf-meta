#!/usr/bin/perl -w

#
# Simplified access to the Xalan XSLT processor.
#

#
# xalanCall
#
# Provides the stem of a "system" call string to access Xalan with the
# required extensions.
#
sub xalanCall
{
	my $xalanRoot = "../tools/xalan";
	
	my $res = "java";
	
	# Endorsed Xalan and Xerces
	$res .= " -Djava.endorsed.dirs=$xalanRoot/endorsed";
	
	# Classpath
	my $classpath = '../bin';
	while (glob "$xalanRoot/lib/*") {
		$classpath .= ':' unless $classpath eq '';
		$classpath .= $_;
	}
	
	$res .= " -cp $classpath";
	
	# Class to invoke
	$res .= " org.apache.xalan.xslt.Process";
	$res;
}

#print ">>>" . xalanCall . "<<<\n";

1;
