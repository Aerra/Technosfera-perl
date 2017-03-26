package DeepClone;

use 5.010;
use strict;
use warnings;

use Data::Dumper;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

sub clone_if
{
	my $orig = shift;
	my $refs = shift;
	my $x;
	if (ref($orig) eq "")
	{
		$x = clone_scalar($orig);
	}
	elsif (ref($orig) eq "ARRAY")
	{
		$x = clone_arr($orig,$refs);
	}
	elsif (ref($orig) eq "HASH")
	{
		$x = clone_hash($orig,$refs);
	}
	elsif (ref($orig)) 
	{
		die undef;
	}
	else 
	{
		$x = undef;		
	}
	return $x;
}

sub clone_arr
{
	my $orig = shift;
	my $refs = shift;
	my @new_arr = ();
	for my $x (@{$orig}) 
	{
		my $y;
		if (ref($x) and $refs->{$x})
		{
			push (@new_arr,$refs->{$x});
		}
		else
		{
			if (ref($x))
			{
				if ($x == $orig)
				{
					$refs->{$x} = \@new_arr;
					push (@new_arr,$refs->{$x});
				}
				else
				{
					$y = clone_if($x,$refs);
					$refs->{$x}=$y;
					push (@new_arr,$y);
				}	
			}
			else
			{
				$y = clone_if($x,$refs);
				push (@new_arr,$y);				
			}
		}
	}
	return \@new_arr;
}

sub clone_hash
{
	my $orig = shift;
	my $refs = shift;
	my %new_hash = ();
	while (my($key, $value) = each (%{$orig}))
	{
		my $y;
		if (ref($value) and $refs->{$value})
		{
			$new_hash{$key} = $refs->{$value};
		}
		else
		{
			if (ref($value))
			{
				if ($value == $orig)
				{
					$refs->{$value} = \%new_hash;
					$new_hash{$key} = $refs->{$value};		
				}
				else
				{
					$y = clone_if($value,$refs);
					$refs->{$value} = $y;
					$new_hash{$key} = $y;
				}
			}
			else
			{
				$y = clone_if($value,$refs);
				$new_hash{$key} = $y;
			}
		}
	}
	return \%new_hash;
}

sub clone_scalar
{
	my $orig = shift;
	return $orig;
}

sub clone
{
	my %refs;
	my $orig = shift;
	my $cloned;
	eval {
		if (defined wantarray)
		{
			$cloned = clone_if($orig, \%refs);
		}
		else
		{
			$cloned = undef;
		}
		return $cloned;		
	}
}

1;