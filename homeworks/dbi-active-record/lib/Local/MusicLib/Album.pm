package Local::MusicLib::Album;


use DBI::ActiveRecord;
use Local::MusicLib::DB::MySQL;
use Local::MusicLib::Main qw(deserial);

use DateTime;

use Mouse::Util::TypeConstraints;

enum 'Type' => qw (single soundtrack collection simple_album);

no Mouse::Util::TypeConstraints;

db "Local::MusicLib::DB::MySQL";

table 'album';

has_field id => (
	isa => 'Int',
	auto_increment => 1,
	index => 'primary',
);

has_field artist_id => (
	isa => 'Int',
	index => 'common',
	default_limit => 25,
);

has_field name => (
	isa => 'Str',
	index => 'common',
	default_limit => 25,
);

has_field year => (
	isa => 'Int',
);

has_field type => (
	isa => 'Str',
	index => 'common',
	default_limit => 25,
	isa => 'Type',

);

has_field create_time => (
	isa => 'DateTime',
	serializer => sub { $_[0]->format_cldr("YYYY-MM-dd HH:mm:ss"); }, 
	deserializer => \&deserial,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;