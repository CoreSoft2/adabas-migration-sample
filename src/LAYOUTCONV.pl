#!/usr/bin/perl -w

use strict;
use Switch;
#use String::Util 'trim';

my $I = 0;
my $J = 0;
my $level = 0;
my $len = 0;
my $plen = 0;
my $peflag = 0;
my $pelevel = 0;
my $x = 1;
my $k = 1;
my $pe = 0;
my $found = 0;
my $y = 1;
my $m = 1;
my $newlen = 0;
my $id = 0;
my $fl = 0;

my $RECORD = "";
my $lname = "";
my $sname = "";
my $type = "";
my $cond1 = "";
my $cond2 = "";
my $cond3 = "";
my $cond4 = "";
my $cond5 = "";
my $tempcmd = "";
my $comma = "";
my $rec = "";
my $occ = "";
my $cmd = "ADADCU FIELDS";
my $dropcmd = "DROP TABLE IF EXISTS adabas_db.employees_nat;";
my $ddlcmd = "CREATE TABLE EMPLOYEES_NAT (";
my $newtype = "";
my $newcond = "";
my $tab = "\t";
my $tabname = "EMPLOYEES_NAT";
my $key = "";
my $idxrec = "";
my $primcond = "";
my $idxfld = "";
my $full = "";
my $short = "";

my @myfile = "";
my @temp = "";
my @emppemuarr = "";
my @temppe = "";
my @indexarr = "";
my @fields = "";
my @tempfl = "";
my @temprec = "";

open(INP, "<C:/SoftwareAG/ADA642_AMN823-CO_Edition_1/Adabas/demodb/emp_nat.fdt" ) || die "Can't open input file $!";
open(EMPPEMU, "<C:/SoftwareAG/ADA642_AMN823-CO_Edition_1/Adabas/emp_natpemu.txt" ) || die "Can't open input file $!";
open(OUT, ">C:/SoftwareAG/ADA642_AMN823-CO_Edition_1/Adabas/transform.bat" ) || die "Can't open output file $!";
open(DDLOUT, ">C:/SoftwareAG/ADA642_AMN823-CO_Edition_1/Adabas/emp_natddl.sql" ) || die "Can't open output file $!";

while (<INP>) {
    chomp;
    push @myfile, $_;
}

close INP;

while (<EMPPEMU>) {
	if (index ($_, '%') + 1 == 1 || index ($_, ' ') + 1 == 1 || index ($_, '-') + 1 == 1 || index ($_, 'Name') + 1 == 1) { next; }
    chomp;
    push @emppemuarr, $_;
}

close EMPPEMU;

# pass the PE field to the PE/MU occurrences report file and get the max occurrences.
sub emppecount() {
	$found = 0;
	foreach $rec (@emppemuarr){
		if (index ($rec, $sname) + 1 == 1) {
#			print ("$rec \n");
			$found = 1;
			@temppe = split(' ', $rec);
			$occ = $temppe[1];
			$occ =~ s/^\s+//;
			$occ =~ s/\s+$//;
		}
		if ($found == 1) { last;}
	}
}

sub binlen() {
	switch($len) {
	case 1 { $plen = 3; }
	case 2 { $plen = 5; }
	case 4 { $plen = 10; }
	case 8 { $plen = 19; }
	else { $plen = $len; }
	}
}

sub fixedlen() {
	switch($len) {
	case 1 { $plen = 3; }
	case 2 { $plen = 5; }
	case 4 { $plen = 10; }
	case 8 { $plen = 19; }
	else { $plen = $len; }
	}
}

sub doublelen() {
	switch($len) {
	case 4 { $plen = 9; }
	case 8 { $plen = 15; }
	else { $plen = $len; }
	}
}

sub fillcmdmu() {
	getnewtyp();
	if ($peflag == 1 && $level > $pelevel) { 
		$y = 1;
		emppecount();
		$y = $occ;
		for ($m = 1; $m <= $y; $m++ ) { 
			$tempcmd = $tempcmd . $comma . $sname . $k . "(" . $m . ")," . $plen . "," . "U"; 
			print DDLOUT "\t$lname" . $k . $m . $tab . "$newtype\t" . $newcond . "\t,\n";
		}
	}
	else {
		$y = 1;
		emppecount();
		$y = $occ;
		for ($m = 1; $m <= $y; $m++ ) { 
			$tempcmd = $tempcmd . $comma . $sname . $m . "," . $plen . "," . "U"; 
			print DDLOUT "\t$lname" . $m . $tab . "$newtype\t" . $newcond . "\t,\n";
		}
		$peflag = 0;
	}
	$comma = ",',',";
}

sub fillcmdnonmu() {
	getnewtyp();
	if ($peflag == 1 && $level > $pelevel) { 
		$tempcmd = $tempcmd . $comma . $sname . $k . "," . $plen . "," . "U"; 
		print DDLOUT "\t$lname" . $k . $tab . "$newtype\t" . $newcond . "\t,\n";
	}
	else {
		$tempcmd = $tempcmd . $comma . $sname . "," . $plen . "," . "U";
		$peflag = 0;
		print DDLOUT "\t$lname" . $tab . "$newtype\t" . $newcond . "\t,\n";
	}
	$comma = ",',',";
}

sub getnewtyp() {
	$newtype = "";
	switch($type) {
	case "A" {
		if ($cond1 eq "FI" || $cond2 eq "FI" || $cond3 eq "FI" || $cond4 eq "FI" || $cond5 eq "FI" || $len < 10) { $newtype = "CHAR(" . $len . ")\t"; }
		else { $newtype = "VARCHAR(" . $len . ")"; }
		}
	case "W" { $newtype = "VARCHAR(" . $len . ")"; }
	case "B" { 
		if ($plen <= 2) { $newtype = "SMALLINT"; }
		else { $newtype = "INT\t"; }
		}
	case "P" { $newtype = "DECIMAL(" . $plen . ",0)"; }
	case "U" {
		if ($len <= 2) { $newtype = "SMALLINT"; }
		else { $newtype = "INT\t"; }
		}
	case "F" { $newtype = "DECIMAL(" . $plen . ",0)"; }
	case "G" { $newtype = "DECIMAL(" . $plen . ",0)"; } 
	else { print ""; }
	}
	
	$full = $lname;
	if ($full eq 'language') { $full = 'language1'; }
	if ($full eq 'curr_code') { $full = 'curr_code1'; }
	if ($full eq 'salary') { $full = 'salary1'; }

	$newcond = "";
	if ($cond1 eq "NU" || $cond2 eq "NU" || $cond3 eq "NU" || $cond4 eq "NU" || $cond5 eq "NU") { 
		if ($type eq "A" || $type eq "W") { $newcond = "DEFAULT ' '\t"; }
		else { $newcond = "DEFAULT 0\t"; }
	}
	if ($cond1 eq "DE" || $cond2 eq "DE" || $cond3 eq "DE" || $cond4 eq "DE" || $cond5 eq "DE") { 
		if ($cond1 eq "UQ" || $cond2 eq "UQ" || $cond3 eq "UQ" || $cond4 eq "UQ" || $cond5 eq "UQ") {
			$newcond = $newcond . "NOT NULL\t";
			if ($primcond eq "") { $primcond = "\tPRIMARY KEY (" . $full ; }
			else { $primcond = $primcond . "," . $full ; }
		}
		else { $id++; $indexarr[$id] = "CREATE INDEX idx_" . $full . " ON " . $tabname . " (" . $full . ");" ; }
	}
	$fl++;
	$fields[$fl] = join("&",$sname,$lname,$type);
}

sub fillindex() {
	@tempfl = split('\=', $RECORD);
	$idxfld = $tempfl[0];
	$idxrec = $tempfl[1];
	@tempfl = "";
	@tempfl = split('\),', $idxrec);
	@temprec = "";
	$id++;
	$indexarr[$id] = "";
	foreach $key ( @tempfl ){
		$key =~ s/\)//;
		@temprec = split('\(', $key);
		$short = $temprec[0];
		getfullname();
		$temprec[1] =~ m/,/;
		$temprec[1] = "(" . $' . ")" ;
		$full =~ m/&/;
		$full = $`;
		if ($full eq 'language') { $full = 'language1'; }
		if ($full eq 'curr_code') { $full = 'curr_code1'; }
		if ($full eq 'salary') { $full = 'salary1'; }
		if ($' eq 'P') { $temprec[1] = "" ; }
		if ($indexarr[$id] eq "") { $indexarr[$id] = "CREATE INDEX idx_" . $idxfld . " ON " . $tabname . " (" . $full . $temprec[1] ; }
		else { $indexarr[$id] = $indexarr[$id] . "," . $full . $temprec[1] ; }
	}
	$indexarr[$id] = $indexarr[$id] . ");" ;
}

sub getfullname() {
	$found = 0;
	$full  = "";
	foreach $rec (@fields){
		if (index ($rec, $short) + 1 == 1) {
			$found = 1;
			$rec =~ m/&/;
			$full = $';
			$full =~ s/^\s+//;
			$full =~ s/\s+$//;
		}
		if ($found == 1) { last;}
	}
}

print DDLOUT "$dropcmd \n";
print DDLOUT "$ddlcmd \n";

for ($I = 1; $I <= $#myfile; $I++ ) {
	@temp = "";
	$RECORD = $myfile[$I];
	if (index ($RECORD, ';') + 1 == 1) { next; }
	if (index ($RECORD, '=') > 0 && index ($RECORD, '(') > 0 && index ($RECORD, ')') > 0 && index ($RECORD, 'PHON') <= 0) { fillindex(); next; }
	if (index ($RECORD, ';') + 1 gt 1) { 
		@temp = split(';', $RECORD); 
		$RECORD = $temp[0];
		$lname = $temp[1];
	}
	@temp = "";
	$level = 0;
	$len = 0;
	$sname = "";
	$type = "";
	$cond1 = "";
	$cond2 = "";
	$cond3 = "";
	$cond4 = "";
	$cond5 = "";
	
	@temp = split(',', $RECORD);
	$J = 0;
	foreach (@temp){
		$temp[$J] =~ s/^\s+//;
		$temp[$J] =~ s/\s+$//;
		$J++;
	}
	$level = $temp[0];
	if (grep(/\D/,$level) == 1) { next; }
	$sname = $temp[1];
	$lname =~ s/^\s+//;
	$lname =~ s/\s+$//;
	$lname =~ s/-/_/;
	if (length ($lname) <= 7) { $tab = "\t\t"; } 
	else { $tab = "\t"; }
	switch($#temp) {
	case 8 {
		$len = $temp[2];
		$type = $temp[3];
		$cond1 = $temp[4];
		$cond2 = $temp[5];
		$cond3 = $temp[6];
		$cond4 = $temp[7];
		$cond5 = $temp[8];
		}
	case 7 {
		$len = $temp[2];
		$type = $temp[3];
		$cond1 = $temp[4];
		$cond2 = $temp[5];
		$cond3 = $temp[6];
		$cond4 = $temp[7];
		}
	case 6 {
		$len = $temp[2];
		$type = $temp[3];
		$cond1 = $temp[4];
		$cond2 = $temp[5];
		$cond3 = $temp[6];
		}
	case 5 {
		$len = $temp[2];
		$type = $temp[3];
		$cond1 = $temp[4];
		$cond2 = $temp[5];
		}
	case 4 {
		$len = $temp[2];
		$type = $temp[3];
		$cond1 = $temp[4];
		}
	case 3 {
		if (grep(/\d/,$temp[2]) == 1) {
			$len = $temp[2];
			$type = $temp[3]; 			
			}
		else { 
			$cond1 = $temp[2]; 
			$cond2 = $temp[3];
			}		
		}
	case 2 {
		if (grep(/\d/,$temp[2]) == 1) { $len = $temp[2]; }
		else { $cond1 = $temp[2]; }		
		}
	else { print ""; }
	}
	if ($level == 1 && $x > 1 && $x > $k) {
		$I = $pe; 
		$k++;
		next; 
	}
	if ($level <= $pelevel) { $peflag = 0; }
	if ($cond1 eq "PE" && $peflag == 0) {
		$pe = $I;
		$pelevel = $level;
		$peflag = 1;
		$x = 1;
		emppecount();
		$x = $occ;
		$k = 1;
		next;
	}
		
	if ($cond1 eq "MU" || $cond2 eq "MU" || $cond3 eq "MU" || $cond4 eq "MU" || $cond5 eq "MU") {
		if ($type eq "A" || $type eq "U" || $type eq "W" || $type eq "G") {
			getnewtyp();
			if ($peflag == 1 && $level > $pelevel) { 
				$y = 1;
				emppecount();
				$y = $occ;
				for ($m = 1; $m <= $y; $m++ ) { 
					if ($cond1 eq "LA" || $cond2 eq "LA" || $cond3 eq "LA" || $cond4 eq "LA" || $cond5 eq "LA" || 
						$cond1 eq "LB" || $cond2 eq "LB" || $cond3 eq "LB" || $cond4 eq "LB" || $cond5 eq "LB" ) {
						$tempcmd = $tempcmd . $comma . $sname . $k . "(" . $m . "),*"; 
					}
					else { $tempcmd = $tempcmd . $comma . $sname . $k . "(" . $m . ")"; }
					print DDLOUT "\t$lname" . $k . $m . $tab . "$newtype\t" . $newcond . "\t,\n";
				}			
			}
			else {
				$y = 1;
				emppecount();
				$y = $occ;
				for ($m = 1; $m <= $y; $m++ ) { 
					if ($cond1 eq "LA" || $cond2 eq "LA" || $cond3 eq "LA" || $cond4 eq "LA" || $cond5 eq "LA" || 
						$cond1 eq "LB" || $cond2 eq "LB" || $cond3 eq "LB" || $cond4 eq "LB" || $cond5 eq "LB" ) {
						$tempcmd = $tempcmd . $comma . $sname . $m . ",*"; 
					}
					else { $tempcmd = $tempcmd . $comma . $sname . $m; }
					print DDLOUT "\t$lname" . $m . $tab . "$newtype\t" . $newcond . "\t,\n";
				}
				$peflag = 0;
			}
			$comma = ",',',";
		}
		elsif ($type eq "P") {
			$plen = ($len * 2) - 1;
			fillcmdmu();
		}
		elsif ($type eq "B") {
			binlen();
			fillcmdmu();
		}
		elsif ($type eq "F") {
			fixedlen();
			fillcmdmu();
		}
#		elsif ($type eq "G") {
#			doublelen();
#			fillcmdmu();
#		}
		else { print ""; }
	}
	else {
		if ($type eq "A" || $type eq "U" || $type eq "W" || $type eq "G") {
			getnewtyp();
			if ($peflag == 1 && $level > $pelevel) { 
				if ($cond1 eq "LA" || $cond2 eq "LA" || $cond3 eq "LA" || $cond4 eq "LA" || $cond5 eq "LA" || 
					$cond1 eq "LB" || $cond2 eq "LB" || $cond3 eq "LB" || $cond4 eq "LB" || $cond5 eq "LB" ) {
					$tempcmd = $tempcmd . $comma . $sname . $k . ",*"; 
				}
				else { $tempcmd = $tempcmd . $comma . $sname . $k; }
				print DDLOUT "\t$lname" . $k . $tab . "$newtype\t" . $newcond . "\t,\n";
			}
			else {
				if ($cond1 eq "LA" || $cond2 eq "LA" || $cond3 eq "LA" || $cond4 eq "LA" || $cond5 eq "LA" || 
					$cond1 eq "LB" || $cond2 eq "LB" || $cond3 eq "LB" || $cond4 eq "LB" || $cond5 eq "LB" ) {
					$tempcmd = $tempcmd . $comma . $sname . ",*"; 
				}
				else { $tempcmd = $tempcmd . $comma . $sname; }
				$peflag = 0;
				print DDLOUT "\t$lname" . $tab . "$newtype\t" . $newcond . "\t,\n";
			}
			$comma = ",',',";
		}
		elsif ($type eq "P") {
			$plen = ($len * 2) - 1;
			fillcmdnonmu();
		}
		elsif ($type eq "B") {
			binlen();
			fillcmdnonmu();
		}
		elsif ($type eq "F") {
			fixedlen();
			fillcmdnonmu();
		}
#		elsif ($type eq "G") {
#			doublelen();
#			fillcmdnonmu();
#		}
		else { print ""; }
	}
}
$cmd = $cmd . " " . $tempcmd . ". " . "RECORD_STRUCTURE=NEWLINE_SEPARATOR";
print OUT "\n$cmd";
if ($primcond ne "") { $primcond = $primcond . ")" ; print DDLOUT "$primcond\n"; }
print DDLOUT ");";
$key = "";
if ($id > 0) {
	foreach $key ( @indexarr ){
		print DDLOUT "\n$key\n";
	}
}
print DDLOUT "\ncommit;";
close OUT;
close DDLOUT;
exit;