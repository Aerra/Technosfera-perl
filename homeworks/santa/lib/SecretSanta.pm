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
	my $leng=$#new_members;
	die "Error in input data! HAHAHA\n" #if error input of members
		if (($leng<=1)||(($leng==2)&&($par>0))||(($leng==3)&&($par==2)));
	my %new_members=@new_members; #hash of members
	my $flag=1;
	my $one = undef;
	my $two = undef;
	for (1..(2*(int(($leng+1)/4))-1))
	{
		if ($flag)
		{
			($one,$two) = keys %new_members; 
			while ((!(defined $new_members{$one}))||(!(defined $new_members{$two}))||(($two cmp $one)==0))
			{
				%new_members=@new_members;
				($one,$two) = keys %new_members; 
			}
			$flag=0; 
			goto "M";
		}
		$one=$two;
		($two)=keys %new_members;
		while ((($two cmp $one)==0)||(!(defined $new_members{$two})))
		{
			@new_members=%new_members;
			%new_members=@new_members;
			($two)=keys %new_members;
		}
M:		push @res, [$one, $two]; 
		push @res, [$new_members{$one},$new_members{$two}];
		delete $new_members{$one};
	}
	delete $new_members{$two};
	my $len=$#res; 
	if ($len == -1)
	{
		($one, $two)=keys %new_members;
		push @res, [$one, $two];
		if (defined $new_members{$one})
		{
			push @res, [$two, $new_members{$one}];
			push @res, [$new_members{$one}, $one];
		}
		else
		{
			push @res, [$two, $new_members{$two}];
			push @res, [$new_members{$two}, $one];
		}
	}
	else
	{
		my $first=@{$res[0]}[0];
		my $first_val=@{$res[1]}[0];
		$one = @{$res[$len-1]}[1];
		$two = @{$res[$len]}[1];
#Viewing the remaining elements of the array
		if (($leng+1)%4==0)
		{
			if ($leng==3)
			{
				push @res, [$two,$first];
				push @res, [$one,$first_val];
			}
			else
			{
				push @res, [$two,$first_val];
				push @res, [$one,$first];
			}
		}
		elsif (($leng+1)%4==1)
		{
			my ($three) = keys %new_members;
			push @res, [$one, $three];
			push @res, [$two, $first];
			push @res, [$three, $first_val]
		}	
			elsif (($leng+1)%4==2)
			{
				my ($three) = keys %new_members;
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
						push @res, [$four,$first];
					}
					else
					{
						$val=$new_members{$four};
						push @res, [$one,$four];
						push @res, [$four,$three];
						push @res, [$three,$first];
					}
					push @res, [$two, $val];
					push @res, [$val, $first_val];
				}
	}		
	return @res;
}



1;