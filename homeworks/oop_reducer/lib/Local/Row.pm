package Local::Row;

use strict;
use warnings;
use DDP;


sub get{
	my ($self, $name, $default)=@_;
	if (exists $self->{$name})
	{
		return $self->{$name};
	}
	else
	{
		return $default;	
	}
}




1;
