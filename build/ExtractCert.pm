#!/usr/bin/perl -w

#
# Simplified access to the ExtractCert utility.
#

#
# extractCertCall
#
# Provides the stem of a "system" call string to access ExtractCert with the
# required extensions.
#
sub extractCertCall
{
	my $extractCertRoot = "../tools/extractcert";
	
	my $res = "java";
	#$res .= " -Djavax.net.debug=ssl:record";
	
	# Classpath
	my $classpath = '';
	while (glob "$extractCertRoot/lib/*") {
		$classpath .= ':' unless $classpath eq '';
		$classpath .= $_;
	}
	
	$res .= " -cp $classpath";
	
	# Class to invoke
	$res .= " uk.ac.sdss.extractcert.ExtractCert";
	$res;
}

#print ">>>" . extractCertCall . "<<<\n";

1;
