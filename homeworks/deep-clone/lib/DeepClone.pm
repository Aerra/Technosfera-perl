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
my %refs;
sub clone_if
{
	my $orig = shift;
	my $x;
	if (ref($orig) eq "")
	{
		$x=clone_scalar($orig);
	}
	elsif (ref($orig) eq "ARRAY")
	{
		$x=clone_mas($orig);
	}
	elsif (ref($orig) eq "HASH")
	{
		$x=clone_hash($orig);
	}
	else 
	{
		$x=undef;
	}
	return $x;
}

sub clone_mas
{
	my $orig = shift;
	my @new_mas=();
	for my $x (@{$orig})
	{
		my $y;
		if ($refs{$x})
		{
			$x=$refs{$x};
		}
		else
		{
			$y=clone_if($x);
			$refs{$x}=$y;
		}
		push (@new_mas,$y);
	}
	return \@new_mas;
}

sub clone_hash
{
	my $orig = shift;
	my %new_hash;
	while (my($key, $value)=each (%{$orig}))
	{
		if ($refs{$value})
		{
			$new_hash{$value}=$refs{$value};
		}
		else
		{
			my $y=clone_if($value);
			$new_hash{$key}=$y;
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
	my $orig=shift;
	my $cloned;
	if (defined wantarray)
	{
		$cloned=clone_if($orig);
	}
	else
	{
		$cloned=undef;
	}
	return $cloned;
}

1;