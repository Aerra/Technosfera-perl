package Local::ConnectSN;

use strict;
use warnings;
use DDP;
use DBI;
use FindBin;
use Config::YAML;
#use Local::Load;
#configyaml;

my $base_class = undef; #inside-out class

sub base_class {
	unless (defined $base_class)
	{

		$base_class = bless {}, shift unless $base_class;
		my $c = Config::YAML -> new (config => "../../etc/config_file");
		$c->write; #?????
		$base_class -> { BD } = DBI->connect(@$c) or die "error in config file: $DBI::errstr!\n";           
	}
	return $base_class;
}

sub DESTROY {
	print "Bye!\n";
}

@EXPORT qw(base_class);

1;