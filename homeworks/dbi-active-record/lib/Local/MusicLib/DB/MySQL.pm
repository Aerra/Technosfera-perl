package Local::MusicLib::DB::MySQL;

use Mouse;
extends 'DBI::ActiveRecord::DB::MySQL';

sub _build_connection_params {
	my ($self) = @_;
	return [
		"dbi:mysql:database=muslib; host=localhost; port=3306",
		"asya",
		"pass",
		{
			"RaiseError" => 1,
			"mysql_enable_utf8" => 1,
		},
	];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;