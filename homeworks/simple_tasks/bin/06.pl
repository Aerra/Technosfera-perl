#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Шифр Цезаря https://ru.wikipedia.org/wiki/%D0%A8%D0%B8%D1%84%D1%80_%D0%A6%D0%B5%D0%B7%D0%B0%D1%80%D1%8F

=head1 encode ($str, $key)

Функция шифрования ASCII строки $str ключом $key.
Пeчатает зашифрованную строку $encoded_str в формате "$encoded_str\n"

Пример:

encode('#abc', 1) - печатает '$bcd'

=cut

sub encode {
    my ($str, $key) = @_;
    my $encoded_str = '';

    # ...
    # Алгоритм шифрования
    # ...
	my @asc = unpack ("C*",$str);
	for (@asc)
	{
		$_=($_+$key)%128;
	}
	$encoded_str = pack("C*", @asc);
    print "$encoded_str\n";
}

encode('#abc',1);
encode('#abc',2);
encode('zzz',1);
encode('Howto learn perl?',25);

=head1 decode ($encoded_str, $key)

Функция дешифрования ASCII строки $encoded_str ключом $key.
Печатает дешифрованную строку $str в формате "$str\n"

Пример:

decode('$bcd', 1) - печатает '#abc'

=cut

sub decode {
    my ($encoded_str, $key) = @_;
    my $str = '';

    # ...
    # Алгоритм дешифрования
    # ...
	my @asc = unpack ("C*",$encoded_str);
	for (@asc)
	{
		$_=($_-$key)%128;
	}
	$str = pack("C*", @asc);
    print "$str\n";
}

decode ('$bcd',1);

1;
