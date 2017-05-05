package Local::Converter;

use strict;
use warnings;
use FindBin;
use IO::Uncompress::Unzip;
use Expoter 'import';

sub install_user {
	my $bd=shift;
	my $zip = new IO::Uncompress::Unzip "$FindBin::Bin/../etc/user.zip" or die "can't unzip;(\n";
	my $sth = $bd->prepare ("INSERT INTO users (id, first_name, $last_name) VALUES (?,?,?)");
	while (<$zip>)
	{
		chomp;
		my ($id, $firstname, $lastname) = split /\s+/, $_;
		$sth -> execute ($id, $firstname, $lastname);
	}
	$bd -> commit;
}

sub install_relation {
	my $bd = shift;
	my $zip = new IO::Uncompress::Unzip "$FindBin::Bin/../etc/user_relation.zip" or die "can't unzip;(\n";
	my $sth = $bd->prepare ("INSERT INTO relations (user1_id, user2_id) VALUES (?,?)");
	while (<$zip>)
	{
		chomp;
		my ($user1_id, $user2_id) = split /\s+/, $_;
		$sth -> execute ($user1_id, $user2_id);
	}
	$bd -> commit;
}

our @EXPORT = qw(install_relation, install_user);

1;