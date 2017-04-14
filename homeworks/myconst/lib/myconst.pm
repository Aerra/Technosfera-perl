package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';
use Exporter qw(import); 
our %declared_constants;
use Data::Dumper;

=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
package aaa;

use myconst math => {
        PI => 3.14,
        E => 2.7,
    },
    ZERO => 0,
    EMPTY_STRING => '';

package bbb;

use aaa qw/:math PI ZERO/;

print ZERO;             # 0
print PI;               # 3.14
=cut

my $normal_constant_name = qr/^_?[^\W_0-9]\w*\z/;
my $tolerable = qr/^[A-Za-z_]\w*\z/;

#sub import
our @EXPORT_OK;
our %EXPORT_TAGS;
my $class = shift;    #здесь должен быть math
#	return unless @_;
	#printf "$class\n";
my $caller = caller; 
my $multiple  = ref $_[0]; 
my $constants;
my $group;
my $pkg; #what?!
# my $symtab = \%{$caller.':'};

	if ($multiple)
	{
		if (ref($_) ne 'HASH') 
		{
			die "Invalide type for constant\n";
		}
		$group=shift;  #here ref to hash
		#printf ("$group\n");
		my $name;
		foreach $name (keys %$group)   #$name is name of constant
		{
			#if ref(%$constants->{$name})
			#{
			#	die "It's not a constant!\n";
			#}
			if ($name !=~ $normal_constant_name or $name !=~ $tolerable)
			{
				die "It's not normal constant name!\n";
			}
			if (looks_like_number($group->{$name}))
			{
				push @EXPORT_OK, $name;
				$EXPORT_TAGS{all}{$name}=$group->{$name};
				$EXPORT_TAGS{$class}{$name}=$group->{$name};	
			}
			else 
			{
				die "It's not a number!\n";
			}
		}
	}
	else
	{
		if (defined $class)
		{
			my $name=shift;
			#die "Can't use undef as constant name\n";
			if ($class !=~ $normal_constant_name or $class !=~ $tolerable)
			{
				die "It's not normal constant name!\n";
			}
			if (looks_like_number($name))
			{
				$EXPORT_TAGS{all}{$class}=$name;
				$EXPORT_TAGS{$class}=$name;	
			}
		}	
	}
1;