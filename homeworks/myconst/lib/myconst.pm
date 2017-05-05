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
our %const_hash;
our %group_hash;


sub import{
	our @EXPORT_OK;
	our %EXPORT_TAGS;
	my ($class, @args) = @_;    #здесь должен быть math
	#return unless @_;
	printf "$class\n";
	die "invalid args checked" if scalar(@args)==1;
	foreach (@args)
	{
		die "Bad arguments!\n" unless (defined $_);
	}
	my %args=(@args);
	my $caller = caller; 
	#my $multiple  = ref $_[0]; 
	my $constant;
	my $group;
	#my $pkg; #what?!
	# my $symtab = \%{$caller.':'}
	#if ($multiple)
	#{
	for my $key (keys %args)
	{
		die "empty const\n" if $key eq '';
		if (ref($args{$key}))
		{
			if (ref($args{$key}) ne 'HASH') 
			{
				die "Invalide type for constant\n";
			}
			die "empty const\n" if $args{$key} eq '';
			$group=$key;  #here ref to hash
			#printf ("$group\n");
			my $name;
			foreach $constant (keys %{$args{$key}})   #$name is name of constant
			{
				#if ($constant !=~ $normal_constant_name or $constant !=~ $tolerable)
				#{
				#	die "It's not normal constant name!\n";
				#}
				#if (looks_like_number($args{$key}{$constant}))
				#{ 
				die "empty const\n" if $constant eq '';
				die "empty const\n" if $args{$key}{$constant} eq '';
				die "empty const\n" if ref $args{$key}{$constant};
				$const_hash{$caller}{$constant}=$args{$key}{$constant};
				$group_hash{all}{$constant}=$args{$key}{$constant};
				$group_hash{$group}{$constant}=$args{$key}{$constant};
				$EXPORT_TAGS{all}{$constant}=$args{$key}{$constant};
				$EXPORT_TAGS{$group}{$constant}=$args{$key}{$constant};	
				#}
				#else 
				#{
				#	die "It's not a number!  $args{$key}{$constant} \n";
				#}
			}
		}
		else
		{
			die "empty const" if $args{$key} eq '';
			$constant=$key;
			#if ($constant !=~ $normal_constant_name or $constant !=~ $tolerable)
			#{
			#	die "It's not normal constant name!\n";
			#}
			#if (looks_like_number($args{$key}))
			#{
			$EXPORT_TAGS{all}{$constant}=$args{$key};
			$const_hash{$caller}{$constant}=$args{$key};
			$group_hash{all}{$constant}=$args{$key};
			#}
			#else 
			#{
			#	die "It's not a number!  $args{$key}  $key \n";
			#}
		}	
	}	
	#}
	no strict 'refs';
	for $constant (keys %{$const_hash{$caller}})
	{
		*{"$caller::$constant"}=sub () {$const_hash{$caller}{$constant};};	
	}

	#*{"$caller"."::import"} = \&Exporter::import;
	my $call=$caller;

	*{"$caller"."::import"} = sub {
		my $pkg = shift;
		my @required= @_;
		my $caller=caller;
		foreach my $r (@required)
		{
			if ($r =~ /^:(.+)$/) 
			{
				for my $key (keys $group_hash{$1})
				{
					my $pf=$1;
					*{"$caller::$key"} = sub () {$group_hash{$pf}{$key};}
				}
			}
			else 
			{
				*{"$caller::$r"} = sub () { $const_hash{$call}{$r};} 
			}
		}
	}
}
1;