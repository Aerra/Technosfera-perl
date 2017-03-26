package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
	# ...
	#	push @res,[ "fromname", "toname" ];
	# ...
	my $par=0;
	#count of partners
	for (@members)
	{
		if (ref())
		{
			$par++;
		}
	}
	my @new_members = map {
		ref() ?	@$_ : $_
	} @members;	
	die "Error in input data!\n" #if error input of members
		unless ((($#new_members==3)&&!($par==0))||(($#new_members==4)&&($par==2)));
	my %new_members=@new_members; #hash of members
	my $flag=1;
	my $one = undef;
	my $two = undef;
	for (0..(2*(int(($#new_members)/4))-1))
	{
		if ($flag)
		{
			($one,$two) = keys %new_members; 
			$flag=0; #remember the first pair of key-value 
			goto "M";
		}
		$one=$two;
		$two=keys %new_members;
M:		push @res, [$one, $two]; 
		push @res, [$new_members{$one},$new_members{$two}];
		delete $new_members{$one};
	}
	delete $new_members{$two};
	my $len=$#res; 
	my $first=@{$res[0]}[0];
	my $first_val=@{$res[1]}[0];
	$one = @{$res[$len-1]}[1];
	$two = @{$res[$len]}[1];
#Viewing the remaining elements of the array
	if ($#new_members%4==0)
	{
		push @res, [$one,$first];
		push @res, [$two,$first_val];
	}
	elsif ($#new_members%4==1)
	{
		my $three = keys %new_members;
		push @res, [$one, $three];
		push @res, [$two, $first];
		push @res, [$three, $first_val]
	}
		elsif ($#new_members%4==2)
		{
			my $three = keys %new_members;
			push @res, [$one, $three];
			push @res, [$two, $new_members{$three}];
			push @res, [$three, $first];
			push @res, [$new_members{$three}, $first_val];
		}
			else 
			{
				my ($three,$four) = keys %new_members;
				my $val=undef;
				if (defined $new_members{$three})
				{
					$val=$new_members{$three};
					push @res, [$one,$three];
					push @res, [$three,$four];
					push @res, [$four,$first_val];
				}
				else
				{
					$val=$new_members{$four};
					push @res, [$one,$four];
					push @res, [$four,$three];
					push @res, [$three,$first_val];
				}
				push @res, [$two, $val];
				push @res, [$val, $first];
			}
	for (@res) {
	say join "→", @$_;
	}
}

calculate (
Рита Игорь
Вадим Катя
Али
Ира
)

1;