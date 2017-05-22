use strict;
use warnings;
use DBI;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::ConnectSN;
use Local::Convert;

my $bd = base_class();

install_user($bd);
install_relation($bd);

#printf "Good connect\n";

$bd->{BD}->disconnect or warn $bd->errstr;

1;
