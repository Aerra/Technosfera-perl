package Local::ConnectSN;

use strict;
use warnings;
use DDP;
use DBI;
use FindBin;
use Config::YAML;
use Exporter qw(import);
#use Local::Load;
#configyaml;

my $base_class = undef; #inside-out class

sub base_class {
	unless (defined $base_class)
	{
		$base_class = bless {}, shift unless $base_class;
		my $c = Config::YAML -> new (config => "$FindBin::Bin/../etc/dbic.yaml");
		#printf "Config::Yaml: \n";
		#p $c;
		#printf  "\n";
		my $cfg = $c->{db};
		#printf "\nConfig::Yaml:db: \n";
		#p $cfg;
		#printf "\n";
		if ($cfg->{dsn} and $cfg->{user} and $cfg->{password})
		{
			$base_class -> { BD } = DBI->connect( $cfg->{dsn}, $cfg->{user}, $cfg->{password},
				{%{$cfg->{args} // {}}, RaiseError => 1, TraceLevel => 1}) 
			or die "error in config file: $DBI::errstr!\n";           
		}
		else
		{
			die "Not enough params!";
		}
	}
	#printf "base_class: \n";
	#p $base_class;
	return $base_class;
}

sub DESTROY {
	print "Destroy the ".__PACKAGE__."\n";
	#print "Bye!\n";
}

our @EXPORT = qw(base_class DESTROY);

1;