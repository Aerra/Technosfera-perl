package Local::SocialNetwork;

use strict;
use warnings;
use Exporter qw(import);
#use FindBin;
#use lib "$FindBin::Bin/../lib";
use Local::ConnectSN;
use Local::Schema::User;
use DDP;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

#friendsXY(1,2);

sub friendsXY {
	printf "In friends!\n";
	my $XX = shift;
	my $YY = shift;
	my $userX = Local::Schema::User->new($XX);
	my $userY = Local::Schema::User->new($YY);
	my @friendsX = @{$userX->get_friends()};
	my @friendsY = @{$userY->get_friends()};
	my @arr;
	my %hash;
	foreach (@friendsX)
	{
		$hash{$_}=1;
	}
	foreach (@friendsY)
	{
		if (defined $hash{$_})
		{
			push @arr, $_;
		}
	}
	my @fr;
	foreach (@arr)
	{
		my $user = Local::Schema::User->new($_);
		push @fr, $user->get_id();
	}
	#p @fr;
	return \@fr;
}

sub nofriends {
	my $dbh = base_class()-> {BD};
	my $sth = $dbh -> selectall_hashref ("SELECT * FROM users WHERE id NOT IN 
		(SELECT user1_id FROM relations)", 'id') || '';
	#printf "No friends: \n";
	#p $sth;
	return $sth;
}

sub handshakers {
	my $XX = shift;
	my $YY = shift;
	my $handshakers=0;
	if (Local::Schema::User->new($XX)->no_friends() or Local::Schema::User->new($YY)->no_friends())
	{
		#Local::ConnectSN->base_class()->disconnect();
		die ("No friends(\n");
	}
	my %handshakers = ($XX => 1);
	while (!defined $handshakers{$YY})
	{
		my @friends = ();
		foreach my $id (keys %handshakers)	
		{
			push @friends, Local::Schema::User->new($id)->get_friends();
		}
		foreach my $i (@friends)
		{
			foreach my $j (@{$i}) 
			{
				$handshakers{$j}=1;
			}
		}
		$handshakers++;
	}
	#printf "Hand: $handshakers\n";
	return {"handshakers" => $handshakers};
}

our @EXPORT = qw(friendsXY nofriends handshakers);

1;
