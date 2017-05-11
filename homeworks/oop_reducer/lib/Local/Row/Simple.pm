package Local::Row::Simple;

use strict;
use warnings;
use DDP;
use parent 'Local::Row';

my $flag;

sub new{
	my($class, %params)=@_;
	#p $class;
	#p %params;
	my @arr=split ',', $params{str};
	my %log;
	$flag=0;
	foreach my $kv (@arr)
	{
		my ($key, $value, $rubbish) = split ':', $kv;
		#p $value;
		if ($value && !($rubbish))
		{
			$log{$key}=$value;
			$flag=1;
		}
		else
		{
			$flag=2;
		}
	}
	#p %log;
	if ($flag==2)
	{
		return undef;
	}
	return bless \%log, $class;
}

1;