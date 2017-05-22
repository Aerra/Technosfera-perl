package Local::MusicLib::Main;

use DateTime;
use Exporter 'import';

sub deserial {
    my $string = shift;
	my @data = $string =~ /^(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)$/;
	my $dt = DateTime->new (
		year       => $data[0],
		month      => $data[1],
		day        => $data[2],
		hour       => $data[3],
		minute     => $data[4],
		second     => $data[5],
	);
	return $dt;
}

@EXPORT = qw (deserial);
