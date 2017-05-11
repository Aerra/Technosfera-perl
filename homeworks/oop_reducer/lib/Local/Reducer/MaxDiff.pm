package Local::Reducer::MaxDiff;

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
	my $top = $self->{top};
	my $bottom = $self->{bottom};
	for (1..$n)
	{
		my $log = $source->next();
		my $row = $row_class->new(str => $log);
		if ($row && looks_like_number($row->get($top,0)) && looks_like_number($row->get($bottom,0)))
		{
			if (($row->get($top,0)-$row->get($bottom,0))>$reduced)
			{
				$reduced=$row->get($top,0)-$row->get($bottom,0);
			}
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
	my $top = $self->{top};
	my $bottom = $self->{bottom};
	while (defined (my $log= ($source->next())))
	{
		my $row = $row_class -> new(str => $log);
		if ($row && looks_like_number($row->get($top,0)) && looks_like_number($row->get($bottom,0)))
		{
			if (($row->get($top,0)-$row->get($bottom,0))>$reduced)
			{
				$reduced=$row->get($top,0)-$row->get($bottom,0);
			}
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
