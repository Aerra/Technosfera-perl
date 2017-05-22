use FindBin;
use lib "$FindBin::Bin/../lib";
use DDP;
use Local::MusicLib::Artist;
use Local::MusicLib::Album;
use Local::MusicLib::Track;

my $create_time = DateTime -> new (
	year       => 2000,
    month      => 10,
    day        => 25,
    hour       => 7,
    minute     => 15,
    second     => 47,
);

my $artist = Local::MusicLib::Artist -> new (
	name => 'Sam Durak',
	country => 'us',
	create_time => $create_time,
);

my $album = Local::MusicLib::Album -> new (
	artist_id => 1,
	name => 'Bad Story',
	year => 1967,
	type => 'collection',
	create_time => $create_time,
);

my $track = Local::MusicLib::Track -> new (
	album_id => 1,
	name => 'Lalala',
	tr_length => '00:43:45',
	create_time => $create_time,
);

$artist->insert;
$album->insert;
$track->insert;

my $art= Local::MusicLib::Artist -> select_by_id ($artist->id);
my $alb= Local::MusicLib::Album -> select_by_id ($album ->id);
my $tra= Local::MusicLib::Track -> select_by_id ($track->id);

p $art;
p $alb;
p $tra;

$art= Local::MusicLib::Artist -> select_by_name ($artist->name);
$alb= Local::MusicLib::Album -> select_by_name ($album ->name);
$tra= Local::MusicLib::Track -> select_by_name ($track->name);

p $art;
p $alb;
p $tra;

$track->name('Человек с ноутбуком');
$track->tr_length('00:03:32');
$track->update;
$album->name('Бабло побеждает зло');
$album->year(2005);
$album->type('soundtrack');
$album->update;
$artist->name ('Ундервуд');
$artist->country('ru');
$artist->update;

$art = Local::MusicLib::Artist -> select_by_id ($artist->id);
$alb = Local::MusicLib::Album -> select_by_id ($album ->id);
$tra = Local::MusicLib::Track -> select_by_id ($track->id);

p $art;
p $alb;
p $tra;

printf "track end\n" if $track->delete;
printf "album end\n" if $album->delete;
printf "artist end\n" if $artist->delete;

1;