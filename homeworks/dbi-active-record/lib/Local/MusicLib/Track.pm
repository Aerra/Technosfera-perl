package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;
use Local::MusicLib::Main qw(deserial);

use DateTime;

db "Local::MusicLib::DB::MySQL";

table 'track';

has_field id => (
	isa => 'Int',
	auto_increment => 1,
	index => 'primary',
);

has_field album_id => (
	isa => 'Int',
	index => 'common',
	default_limit => 25,
);

has_field name => (
	isa => 'Str',
	index => 'common',
	default_limit => 25,
);

has_field tr_length => (
	isa => 'Str',
	serializer => sub { my ($h,$m,$s) = split /:/, $_[0]; return $h*3600+$m*60+$s; }, 
	deserializer => sub { return sprintf ("%.2d:%.2d:%.2d", int($_[0] / 3600), int($_[0] / 60)%60, $_[0]%60)},
);

has_field create_time => (
	isa => 'DateTime',
	serializer => sub { $_[0]->format_cldr("YYYY-MM-dd HH:mm:ss"); }, 
	deserializer => \&deserial,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;