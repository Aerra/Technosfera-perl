package Local::Source::Text;

use parent 'Local::Source';
use strict;
use warnings;
use DDP;

my $chet=0;
my $self1;

sub next {
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
	my $del;
	if (defined $self->{delimiter})
	{
		$del=$self->{delimiter};
	}
	else
	{
		$del='\n';
	}
	#printf "$del\n";
	my @text=split $del, $self->{text};
	#p @text;
	my $res=$text[$chet];
	$chet++;
	return $res;
}

1;