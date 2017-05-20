package Local::Schema::User;

use strict;
use warnings;
use DDP;
#use FindBin;
#use lib "$FindBin::Bin/../lib";
#use Local::Schema::Relation;
use Local::ConnectSN;
use utf8;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('users');
__PACKAGE__->add_columns(
	id => {
		data_type => 'integer',
	},
	first_name => {
		data_type => 'varchar',
		size => 255,
	},
	last_name => {
		data_type => 'varchar',
		size => 255,
	}
) charset utf8;
__PACKAGE__->set_primary_key('id');


sub new {
	my $class = shift;
	my $id = shift;
	#printf "New: $id\n";
	my $self = bless {}, $class;
	my $dbh = Local::ConnectSN -> base_class()-> {BD};
	my $sth = $dbh -> prepare ("SELECT users.first_name, users.last_name, 
		relations.user2_id FROM users INNER JOIN relations ON users.id=relations.user1_id 
		WHERE users.id=(?)");
	$sth -> execute ($id);
	my $user = $sth -> fetchrow_hashref();
	#printf "User: \n";
	#p $user;
	my @friends = map {$_->[2]} @{$sth->fetchall_arrayref()};
	#printf "Friends: \n";
	#p @friends;
	($self)->{id} = $id;
	($self)->{first_name} = ($user)->{first_name};
	($self)->{last_name} = ($user)->{last_name};
	($self)->{friends} = \@friends;
	return $self;
}

sub get_name {
	my $self = shift;
	return ($self)->{first_name}." ".($self)->{last_name};
}

sub get_friends {
	my $self = shift;
	return ($self)->{friends};
}

sub get_id {
	my $self = shift;
	my %hash;
	$hash{id}=($self)->{id};
	$hash{name}=$self->get_name();
	return \%hash;
}

sub no_friends {
	my $self = shift;
	return 1 unless (scalar @{($self)->{friends}});
	return 0;
}

1;
