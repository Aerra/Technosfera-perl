package Local::MusicLib::Artist;

use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;
use Local::MusicLib::Main qw(deserial);


use DateTime;

db "Local::MusicLib::DB::MySQL";

table 'artist';

has_field id => (
	isa => 'Int',
	auto_increment => 1,
	index => 'primary',
);

has_field name => (
	isa => 'Str',
	index => 'common',
	default_limit => 25,
);

has_field country => (
	isa => 'Str',
);

has_field create_time => (
	isa => 'DateTime',
	serializer => sub { $_[0]->format_cldr("YYYY-MM-dd HH:mm:ss"); }, 
	deserializer => \&deserial,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;