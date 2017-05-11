package Local::Source::Array;

use parent 'Local::Source';
use strict;
use warnings;
use DDP;

my $chet=0;
my $self1;

sub next {
	#printf "hello2!\n";
	my $self = shift;
	if ($chet==0)
	{
		$self1=$self;
	}
	unless ($self1 eq $self)
	{
		$chet=0;
		$self1=$self;
	}
	#p $self;
	#printf "params: ";
	#p %params;
	my $array = $self->{array};
	if ($array->[$chet])
	{
		my $res = $array->[$chet];
		#printf "res: $res\n";
		#my $res=shift @{$array};
		#p $res;
		#$self->{array}=$array;
		$chet++;
		return $res;
	}
	else
	{
		return undef;
	}
}


1;
