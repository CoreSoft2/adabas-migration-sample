#!/usr/bin/perl -w

use strict;
use Switch;
#use String::Util 'trim';

my $I = 0;

my $dbname = "ADABAS_DB";
my $tabname = "EMPLOYEES_NAT";
my $OUTREC = "";
my $comma = "";
my $RECORD = "";
my $key = "";

my @myfile = "";
my @temp = "";

open(INP, "<C:/SoftwareAG/ADA642_AMN823-CO_Edition_1/Adabas/DCUOUT" ) || die "Can't open input file $!";
open(OUT, ">C:/SoftwareAG/ADA642_AMN823-CO_Edition_1/Adabas/insert_script.sql" ) || die "Can't open output file $!";

while (<INP>) {
    chomp;
    push @myfile, $_;
}
close INP;

print "Total number of recs are $#myfile \n";
print OUT "INSERT INTO " . $dbname . "." . $tabname . " VALUES \n";

for ($I = 1; $I <= $#myfile; $I++ ) {
	@temp = "";
	$RECORD = $myfile[$I];
	@temp = split(',', $RECORD);
	$OUTREC = "";
	$comma = "";
	$key = "";
	foreach $key ( @temp ){
		$key =~ s/'/\\'/;
		$OUTREC = $OUTREC . $comma . "'" . $key . "'";
		$comma = ",";
	}
	if ($I == $#myfile) { print OUT "(" . $OUTREC . ");\n"; }
	else { print OUT "(" . $OUTREC . "),\n"; }
}
print OUT "COMMIT;";
close OUT;
exit;