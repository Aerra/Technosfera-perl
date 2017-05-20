package Local::Convert;

use strict;
use warnings;
use FindBin;
use DBI;
use IO::Uncompress::Unzip;
use Exporter 'import';
use DDP;
use Encode qw (decode encode);

sub install_user {
	printf "\ninstall user\n";
	my $bd=shift;
	my $zip = new IO::Uncompress::Unzip "$FindBin::Bin/../etc/user.zip" 
	or die "can't unzip;(\n";
	my $sth = $bd->{BD}->prepare ("REPLACE INTO users (id, first_name, last_name) VALUES (?,?,?)");
	while (<$zip>)
	{
		chomp;
		my ($id, $firstname, $lastname) = split /\s+/, $_;
		printf "$id, $firstname, $lastname\n";
		$id = decode ('UTF-8', $id);
		$firstname= decode ('UTF-8', $firstname);
		$lastname= decode ('UTF-8', $lastname);
		$sth -> execute ($id, $firstname, $lastname);
	}
	$bd->{BD}->commit;
}

sub install_relation {
	printf "\n\n\n install relation\n";
	my $bd = shift;
	my $zip = new IO::Uncompress::Unzip "$FindBin::Bin/../etc/user_relation.zip" 
	or die "can't unzip;(\n";
	my @relations;
	my $num;
	my $one=100000;
	while (my $line = $zip->getline)
	{
		$num++;
	#	printf "$_\n";
		my ($user1_id, $user2_id) = split /\s+/, $line;
	#	$user1_id = decode ('UTF-8', $user1_id);
	#	$user2_id = decode ('UTF-8', $user2_id);
		push @relations, "$user1_id,$user2_id";
		if ($num%$one==0)
		{
			my $buf = join '),(',@relations;
			my $str = "REPLACE INTO relations (user1_id, user2_id) VALUES (".$buf.")";
			my $sth = $bd->{BD}->prepare ($str);
			$sth -> execute();
			$bd->{BD}->commit;
			@relations = ();
		}
	}
	if (@relations)
	{
		my $buf = join '),(',@relations;
		my $str = "REPLACE INTO relations (user1_id, user2_id) VALUES (".$buf.")";
		my $sth = $bd->{BD}->prepare ($str);
		$sth -> execute();
		$bd->{BD}->commit;
	}
	printf "\ninsert is create, now i create index\n";
	my $sth = $bd->{BD}->prepare("CREATE INDEX user1_id_idx on relations (user1_id)");
	$sth -> execute();
	$sth = $bd->{BD}->prepare("CREATE INDEX user2_id_idx on relations (user2_id)");
	$sth -> execute();
	printf "All good\n";
}

our @EXPORT = qw(install_relation install_user);

1;