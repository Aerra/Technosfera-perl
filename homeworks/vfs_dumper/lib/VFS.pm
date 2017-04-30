package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';
use DDP;
use JSON::XS;
use FindBin;
use Encode;
use lib "$FindBin::Bin/../lib";


=encoding UTF8

=head1 NAME

Дерево сериализовано в последовательность команд. Команда кодируется одним байтом, за ней могут следовать аргументы, в зависимости от типа команды.

* D — создание директории. Любое непустое дерево должно начинаться с этой команды и следующей за ней командой I. За командой следуют следующие аргументы, в указанном порядке:
  + длина имени директории — 2-х байтное беззнаковое целое, big endian.
  + имя директории — указанное в предыдущем поле число байт, utf8
  + права доступа — 2-х байтное беззнаковое целое, big endian.
* F — создание файла
  + длина имени файла — 2-х байтное беззнаковое целое, big endian.
  + имя файла — указанное в предыдущем поле число байт, utf8
  + права доступа — 2-х байтное беззнаковое целое, big endian.
  + размер файла — 4-х байтное беззнаковое целое, big endian.
  + sha1 от содержимого файла — 20 байт (не hex!)
* I — спуск по дереву вниз, в директорию, созданную предыдущей командой. Вторая команда в любом не пустом дереве.
* U — подъём по дереву вверх. Подняться на уровень корневой директории можно только в предпоследней команде в последовательности.
* Z — Признак окончания дерева. Должна быть последней командой, в случае пустого дерева — единственной

Права доступа сериализуются по следующему правилу:

* other:
  + execute => 1 бит
  + write   => 2 бит
  + read    => 4 бит
* group
  + execute => 8 бит
  + write   => 16 бит
  + read    => 32 бит
* user
  + execute => 64 бит
  + write   => 128 бит
  + read    => 256 бит

Представление в JSON
--------------------

Пустое дерево сериализуется как пустой объект — «{}» Не пустое дерево представляет собой директорию, содержащую в поле list объекты уровнем ниже — директории и файлы Вложенные директории могут, в свою очередь, содержать вложенные объекты. 

=cut

#sub read_file {
#	open my $file, "<", "$_[0]" or die "Can't open file $_[0]";
#	local $/ = undef;
#	return <$file>;
#}
#
#p parse(read_file("$FindBin::Bin/../data/example3.bin"));

#mode2s (305);

sub mode2s {
	# Тут был полезный код для распаковки численного представления прав доступа
	# но какой-то злодей всё удалил.
	my $access = shift;
	my @access= ('other', 'group', 'user');
	my %mode;
	for my $i (0..2) {
		$mode{$access[$i]}{execute} = $access & 2**($i*3) ? JSON::XS::true : JSON::XS::false;
		$mode{$access[$i]}{write} = $access & 2**($i*3+1) ? JSON::XS::true : JSON::XS::false;
		$mode{$access[$i]}{read} = $access & 2**($i*3+2) ? JSON::XS::true : JSON::XS::false;
	}
	return \%mode;
}

my $buf;

sub D {
	my %json_analyze;
	my ($length, $root, $name);
	($length, $buf) = unpack ("n A*", $buf);
	($name, $root, $buf) = unpack ("A$length n A*", $buf);
	$json_analyze{type}='directory';
	$json_analyze{name}=decode ('utf8', $name);
	$json_analyze{mode}=mode2s($root);
	return \%json_analyze;
}


sub F {
	my %json_analyze;
	my ($length, $name, $root, $size, $sha1);
	($length, $buf) = unpack ("n A*", $buf);
	($name, $root, $size, $sha1, $buf) = unpack ("A$length n N A20 A*", $buf);
	$json_analyze{type}='file';
	$json_analyze{name}=decode ('utf8', $name);
	$json_analyze{mode}=mode2s($root);
	$json_analyze{size}=$size;
	$json_analyze{hash}=unpack 'H*', $sha1;
	return \%json_analyze;
}


sub parse {
	$buf=shift;
	my $flag=unpack "A", $buf;
	if ($flag eq 'Z')
	{
		return {};
	}
	elsif ($flag eq 'D')
	{
		my $a=last1();
		return $a->[0];
	}
	else 
	{
		die "The blob should start from 'D' or 'Z'";
	}
}


sub last1 {
	my @json_analyze;
	while ((my $analyze, $buf)=unpack("A A*", $buf))
	{
		if ($analyze eq 'Z')
		{ 
			die "Garbage ae the end of the buffer" if ($buf);
			return \@json_analyze;
		}
		elsif ($analyze eq 'D')
		{
			push @json_analyze, D();
		}
		elsif ($analyze eq 'I')
		{
			$json_analyze[-1]->{list}=last1($buf); 
		}
		elsif ($analyze eq 'F')
		{
			push @json_analyze, F();
		}
		elsif ($analyze eq 'U')
		{
			return \@json_analyze;
		}
	}	
}

1;
