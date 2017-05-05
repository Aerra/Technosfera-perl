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

#DBI::mysql::database : socialnet; host : localhost; port : 3306
#user : anna
#password : pass
#RaiseError : 1
#mysql_enable_utf8 : 1

my $base_class = undef; #inside-out class

sub base_class {
	unless (defined $base_class)
	{
		$base_class = bless {}, shift unless $base_class;
		print "EEEE\n";
		my $c = Config::YAML -> new (config => "../etc/config_file");
		#$c->write; #?????
		p $c;
		$base_class -> { BD } = DBI->connect($c) or die "error in config file: $DBI::errstr!\n";           
		#что передавать в коннект??? ссылку на что? массив или хеш? ведь массив по идее, но конфигямл возвращает хеш(
	}
	return $base_class;
}

sub DESTROY {
	print "Bye!\n";
}

our @EXPORT = qw(base_class);

1;