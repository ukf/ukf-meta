#!/usr/bin/perl -w
#
# Query tool for showing information about entities in a SAML metadata aggregate.
# Useful when there are multiple registration authorities.
#
use strict;
use Getopt::Long;
use XML::Twig;
$| = 1;

my $DEBUG;
$DEBUG = 0;

sub help {
	print<<'EOF';

usage: query-entities.pl [--help] [--head] [--entityID] [--idp] [--sp] [--reg <registrationAuthority>] [--notreg <registrationAuthority>] <file>

Outputs the entityID, display name(s) and other information about entities in the given SAML metadata aggregate file.

--help			- prints this help and exits

--head			- prints out a header for the CSV file
--entityID		- outputs a list of entityIDs only
	(can only have one of --head and --entityID specified)

--idp 			- only outputs IdPs
--sp			- only outputs SPs
	(By default the script outputs all IdP and SP entities)

--reg <registrationAuthority>		- outputs entities registered by registrationAuthority
--notreg <registrationAuthority>	- outputs those entities NOT registered by registrationAuthority
	(By default the script outputs all entities; can only have one of --reg or --notreg)
	
Example 1:
To output all SPs in the UK federation metadata which have been imported (i.e. are not registered by the UKAMF registrationAuthority http://ukfederation.org.uk), and to include a header on the CSV file:

query-entities.pl --head --sp --notreg http://ukfederation.org.uk ukfederation-metadata.xml 

Example 2:
To output all IdPs exported by the UK federation, and include a header

query-entities.pl --head --idp -reg http://ukfederation.org.uk ukfederation-export.xml

EOF
}

my $idp;
my $sp;
my $reg;
my $notreg;
my $help;
my $head;
my $entityID;

my $result = GetOptions(
		"idp" => \$idp,
		"sp" => \$sp,	
		"reg=s" => \$reg,
		"notreg=s" => \$notreg,
		"help" => \$help,
		"head" => \$head,
		"entityID" => \$entityID
		);

if ($help) {
	help();
	exit 0;
}

#
# Input checking
#

if (!$ARGV[0]) {
	print "\nError: you must define an input file\n";
	help();
	exit 1;
}

if ( ! -r $ARGV[0] ) {
	print "\nError: input file $ARGV[0] must be readable\n";
	help();
	exit 2;
}

my $infile = $ARGV[0];

# If no IdP/SP discriminator set, 
if ( ! $idp && ! $sp ) { $idp = 1; $sp = 1; }

# Can only have one of -reg and -notreg set
if ( $reg && $notreg ) {
	print "\nError: can only have one of --reg and --notreg set at the same time\n";
	help();
	exit 3;
}

# Can only have one of --head and --entityID
if ( $head && $entityID ) {
	print "\nError: can only have one of --head and --entityID set at the same time\n";
	help();
	exit 3
}

#
# Debug printing of input flags
#
if ($DEBUG) {
	if ($idp) { print "idp: $idp\n"; }
	if ($sp) { print "sp: $sp\n"; }
	if ($reg) { print "reg: $reg\n"; }
	if ($notreg) { print "notreg: $notreg\n"; }
}

#
# Get contents of file
#
my $xml;
$DEBUG && print "input file: $infile\n";
open(FILE, $infile) || die "Error: could not open $infile";
while (<FILE>) { $xml .= $_; }
close FILE;
if (!length $xml) {
	print "Error: length of file $infile is zero\n";
	exit 4;
}

#
# print header
#
if ($head) { print "# type, entityID, registrationAuthority, OrganizationDisplayName, OrganizationURL\n"; }

#
# Workhorse
#
my $twig = XML::Twig->new(
		pretty_print => "indented",
		twig_handlers =>
		{
			'EntityDescriptor' => \&is_entity
		},
	);
$twig->parse($xml);

sub is_entity () {
	my ($t, $section)= @_;
	my ($entityID, $ODN, $URL, $registrationAuthority, $type, $temp);

	$entityID = "No entityID found";
	$entityID = $section->{'att'}->{'entityID'};

	$ODN = "No OrganizationDisplayName found";
	$URL = "No URL found";	
	# Turns out the Organization element is optional
	if ( $section->first_child('Organization') ) {
		if ( $section->first_child('Organization')->first_child('OrganizationDisplayName[@xml:lang="en"]') ) {
			if ( $temp = $section->first_child('Organization')->first_child('OrganizationDisplayName[@xml:lang="en"]')->text) {
				$ODN = $temp;
			}
		}
		if ( $section->first_child('Organization')->first_child('OrganizationURL') ) {
			if ( $temp = $section->first_child('Organization')->first_child('OrganizationURL')->text) {
				$URL = $temp;
			}
		}	
	}
	
	$registrationAuthority = "No registrationAuthority found";
	if ( $temp = $section->first_child('Extensions')->first_child('mdrpi:RegistrationInfo')->{'att'}->{'registrationAuthority'} ) {
		$registrationAuthority = $temp;
	}
	
	if ( $notreg && $notreg eq $registrationAuthority ) { return; }
	if ( $reg && $reg ne $registrationAuthority ) { return; }

	$type = "Unknown";
	if ( $section->first_child('IDPSSODescriptor') ) { $type = "IdP"; }
	if ( $section->first_child('SPSSODescriptor') ) { $type = "SP"; }	

	if ( ($sp && $type eq "SP") || ($idp && $type eq "IdP") ) {
		if ($entityID) {
			print "$entityID\n";
		} else {	
			print "$type, $entityID, $registrationAuthority, \"$ODN\", $URL\n"
		}
	}
}
