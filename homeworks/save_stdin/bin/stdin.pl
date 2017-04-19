#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use DDP;
use utf8;

#...
$SIG{INT} = \&intwork;


our $all=0;
our $len=0;
print "Get ready\n";
my $filename;
GetOptions("file=s" => \$filename);
#p $filename;
open (our $fh, '>', "$filename") or die "Can't open this file!\n";
while (<STDIN>) {
		$all+=1;
		$len=$len + length($_)-1;
		print {$fh} $_;
		if (eof())
		{
			#my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
			select (STDOUT);
			printf ("$len $all %.0f\n", $len/$all);
			exit();
		}
	}

sub intwork {
	select (STDERR);
	print "Double Ctrl+C for exit";
	$SIG{INT} = \&intwork1;
}

sub intwork1 {
	close ($fh);
	#print "\n$len ";
	#print "$all ";
	select (STDOUT);
	printf ("$len $all %.0f", $len/$all);
	exit ();
}

1;