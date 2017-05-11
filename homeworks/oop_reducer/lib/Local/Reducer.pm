package Local::Reducer;

use strict;
use warnings;
use Local::Row;
use Local::Source;

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


sub new{
	my ($class, %params) = @_;
	$params{reduced}=$params{initial_value};
	delete $params{initial_value};
	return bless \%params, $class;
}

1;
