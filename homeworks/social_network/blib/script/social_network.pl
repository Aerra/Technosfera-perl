#!/usr/bin/env perl

use strict;
use warnings;
use DDP;
use DBI;
use Getopt::Long;
#use JSON::XS;
use JSON;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::SocialNetwork;
use Local::ConnectSN;
use Local::Convert;
use Local::Schema::User;


my $command = shift;
die "it is not a command!\n" unless (defined $command);
my @users;
GetOptions("user=i", \@users);


#my $bd = base_class();
#install_user($bd);
#install_relation($bd);
#$bd->disconnect();


if ($command eq 'friends')
{
	#printf "Yes!\n";
	die "you must have two users!\n" if ($#users != 1);
	print JSON->new->utf8->encode(friendsXY(@users));
}
elsif ($command eq 'nofriends')
{
	die "no parametres!\n" if ($users[0]);
	print JSON->new->utf8->encode(nofriends());
}
elsif ($command eq 'num_handshakes')
{
	die "you must have two users!\n" if ($#users != 1);
	print JSON->new->utf8->encode(handshakers(@users));
}
else 
{
	die "wrong command!\n";
}



1;