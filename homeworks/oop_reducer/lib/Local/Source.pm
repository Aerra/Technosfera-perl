package Local::Source;

use strict;
use warnings;
use DDP;



sub new{
	#printf "Hello!\n";
	my ($class, %params)=@_;
	#p $class;
	#p %params;
	#p my $self=bless \%params, $class;
	return bless \%params, $class;
	#return $self;
}

#sub next{
#	my $self=shift;

#}



1;