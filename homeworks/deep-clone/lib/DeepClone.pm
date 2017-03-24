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

our $refs={};  #хэш для циклических ссылок

sub clone {
	my $orig = shift;
	my $cloned;
	# ...
	# deep clone algorith here
	# ...
	if (wantarray)
	{
		die "Error in input data. It is not scalar!\n";
	}
	elsif (defined wantarray)
	{
		if (ref($orig) eq "")
		{
			$cloned=$orig;
		}
		elsif (ref($orig) eq "ARRAY")
		{
			my @new_mas=();
			foreach my $x (@{$orig})
			{
				if ($refs->{$x})
				{
					push (@new_mas, $refs->{$x});
				}
				else
				{
					if (ref($x) eq "")
					{
						push(@new_mas,$x);	
					}
					elsif (ref($x) eq "ARRAY")
					{
						my @new_mas_1=();
						foreach my $y (@{$x})
						{
							if (!(ref($y) eq ""))
							{
								$y=clone($y);
							}
							push(@new_mas_1,$y);
						}
						push (@new_mas,\@new_mas_1);
						$refs->{$x}=\@new_mas_1;
					}
					elsif (ref($x) eq "HASH")
					{
						my %new_hash_1;
						while (my($key, $value)=each (%{$x}))
						{
							if (!(ref($value) eq ""))
							{
								$value=clone($value);
							}
							$new_hash_1{$key}=$value;
						}
						push(@new_mas, \%new_hash_1);
						$refs->{$x}=\%new_hash_1;
					}
				}
			}
			$cloned=\@new_mas;
		}
		elsif (ref($orig) eq "HASH")
		{
			my @new_hash=();
			while (my($key, $value)=each (%{$orig}))
			{
					if ($refs->{$value})
					{
						push(@new_hash,$refs->{$value});
					}
					else
					{
						if (ref($value) eq "")
						{
							push(@new_hash,$value);
						}
						elsif (ref($value) eq "ARRAY")
						{
							my @new_mas_1=();
							foreach my $y (@{$value})
							{
								if (!(ref($y) eq ""))
								{
									$y=clone($y);
								}
								push(@new_mas_1,$y);
							}
							push(@new_hash,\@new_mas_1);
							$refs->{$value}=\@new_mas_1;
						}
						elsif (ref($value) eq "HASH")
						{
							my %new_hash_1={};
							while (my($key, $value1)=each (%{$value}))
							{
								if (!(ref($value1) eq ""))
								{
									$value1=clone($value1);
								}
								$new_hash_1{$key}=$value1;
							}	
							push(@new_hash,\%new_hash_1);
							$refs->{$value}=\%new_hash_1;
						}
					}
			}
			my %new_hash=@new_hash;	
			$cloned=\%new_hash;
		}
		else 
		{
			die "Error in input data.\n";
		}
	}
	else
	{
		$cloned=undef;
	}
	return $cloned;
}

1;
