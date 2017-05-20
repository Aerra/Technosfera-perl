package Local::Schema::Relation;

use strict;
use warnings;
use DDP;
use Local::ConnectSN;
use utf8;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('relations');
__PACKAGE__->add_columns(
	id => {
		data_type => 'integer',
		is_auto_increment => 1,
	},
	user1_id => {
		data_type => 'integer',
	},
	user2_id => {
		data_type => 'integer',
	},
#	friends => {
#
#	}
);
__PACKAGE__->set_primary_key('id');


1;