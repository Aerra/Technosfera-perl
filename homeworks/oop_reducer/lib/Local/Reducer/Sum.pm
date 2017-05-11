package Local::Reducer::Sum;

use parent 'Local::Reducer';
use DDP;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

sub reduce_n{
	my $self = shift ;
	my $n = shift;
	my $source = $self->{source};
	my $row_class = $self->{row_class};
	my $reduced = $self->{reduced};
	my $field = $self->{field};
	for (1..$n)
	{
		my $log = $source->next();
		my $row = $row_class->new(str => $log);
		if ($row && looks_like_number($row->get($field, 0)))
		{
			$reduced += $row->get($field,0);
		}
	}
	$self->{reduced}=$reduced;
	return $reduced;
}

sub reduce_all{
	my $self = shift;
	my $source = $self->{source};
	my $row_class = $self->{row_class};
	my $reduced = $self->{reduced};
	my $field = $self->{field};
	while (defined (my $log = ($source->next())))
	{
		my $row = $row_class -> new(str => $log);
		if ($row && looks_like_number($row->get($field, 0)))
		{
			$reduced += $row->get($field,0);
		}
	}
	$self->{reduced}=$reduced;
	return $reduced;
}

sub reduced{
	my $self = shift;
	return $self->{reduced};
}

1;