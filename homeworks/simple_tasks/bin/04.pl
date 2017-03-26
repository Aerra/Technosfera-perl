#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Поиск номера первого ненулевого бита.

=head1 run ($x)

Функция поиска первого ненулевого бита в 32-битном числе (кроме 0).
Пачатает номер первого ненулевого бита в виде "$num\n"

Примеры: 

run(1) - печатает "0\n".

run(4) - печатает "2\n"

run(6) - печатает "1\n"

=cut

sub run {
    my ($x) = @_;
    my $num = 0;

    # ...
    # Вычисление номера первого ненулевого бита 
    # ...
	if ($x != 0)
	{
		while ($x%2==0)
		{
			$num +=1;
			$x=$x/2;
		}
  	 	print "$num\n";
	}
	else 
	{
		print "0\n";
	}
}

run(1);
run(4);
run(6);
run(0);
run(8);

1;
