package Local::Schema::User;

use strict;
use warnings;
use DDP;
#use Local::Schema::Relation;
use Local::ConnectSN;
use utf8;
#use base qw(DBIx::Class::Core);

#__PACKAGE__->table('users');
#__PACKAGE__->add_columns(
#	id => {
#		data_type => 'integer',
#		is_auto_increment => 1,
#	},
#	first_name => {
#		data_type => 'varchar',
#		size => 64,
#	},
#	last_name => {
#		data_type => 'varchar',
#		size => 64,
#	},
##	friends => {
##
##	}
#);
#__PACKAGE__->set_primary_key('id');

sub new {
	my $class = shift;
	my $id = shift;
	my $self = bless {}, $class;
	my $dbh = base_class()-> {BD};
	my $sth = $dbh -> prepare ("SELECT users.first_name, users.last_name, 
		relations.user1_id FROM users INNER JOIN relations ON users.id=relations.user1_id
		 WHERE id=?");
	$sth -> execute ($id);
	my $user = $sth -> fetchrow_hashref();
	my @friends = map {$_->[2]} @{$sth->fetchall_arrayref()};
	$self{id} = $id;
	$self{first_name} = $user{first_name};
	$self{last_name} = $user{last_name};
	$self{friends} = \@friends;
	return $self;
}

sub get_name {
	my $self = shift;
	return $self{first_name}." ".$self{last_name};
}

sub get_friends {
	my $self = shift;
	return $self{friends};
}

sub get_id {
	my $self = shift;
	my %hash;
	$hash{id}=$self{id};
	$hash{name}=$self->get_name();
	return \%hash;
}

sub no_friends {
	my $self = shift;
	return 1 unless (scalar @{$self{friends}});
	return 0;
}

1;