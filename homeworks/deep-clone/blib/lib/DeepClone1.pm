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
		my $refs={};    #хэш для циклических циклов
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
							$new_hash_1{$key}=$value;
						}
						push(@new_mas, \%new_hash_1);
						$refs->{$x}=\%new_hash_1;
					}
					else
					{
						die "Error in input data!\n";
					}
				}

			}
			$cloned=\@new_mas;
		}
		elsif (ref($orig) eq "HASH")
		{
			my @new_hash=();
			my %new_hash={};
			while (my($key, $value)=each (%{$orig}))
			{
				for ($key, $value)
				{
					if ($refs->{$_})
					{
						push(@new_hash,$refs->{$_});
					}
					else
					{
						if (ref($_) eq "")
						{
							push(@new_hash,$_);
						}
						elsif (ref($_) eq "ARRAY")
						{
							my @new_mas_1=();
							foreach my $y (@{$_})
							{
								push(@new_mas_1,$y);
							}
							push(@new_hash,\@new_mas_1);
							$refs->{$_}=\@new_mas_1;
						}
						elsif (ref($_) eq "HASH")
						{
							my %new_hash_1;
							while (my($key, $value)=each (%{$_}))
							{
								$new_hash_1{$key}=$value;
							}	
							push(@new_hash,\%new_hash_1);
							$refs->{$_}=\%new_hash_1;
						}
#						else
#						{
#							die "Error in input data!\n";
#						}
					}
				}
			}
				
#			foreach my $x (@{$orig})
#			{
#				push(@new_mas,$x);
#			}
#			my %new_hash=@new_mas;
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
