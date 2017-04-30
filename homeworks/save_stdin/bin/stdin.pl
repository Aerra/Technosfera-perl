#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use DDP;
use utf8;

#...
$SIG{INT} = \&intwork;

my $flag=0;
our $all=0;
our $len=0;
my $filename;
GetOptions("file=s" => \$filename);
#p $filename;
open (our $fh, '>', "$filename") or die "Can't open this file!\n";
print "Get ready\n";
while (<STDIN>) {
		$flag=0;
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
	$flag=1;
	select (STDERR);
	print "Double Ctrl+C for exit";
	$SIG{INT} = \&intwork1;
}

sub intwork1 {
	if ($flag == 0) 
	{ 
		select (STDERR);
		print "Double Ctrl+C for exit";
		$SIG{INT} = \&intwork;
	}
	else
	{
		close ($fh);
		select (STDOUT);
		printf ("$len $all %.0f", $len/$all);
		exit ();
	}
	#print "\n$len ";
	#print "$all ";
}

1;