package Local::MatrixMultiplier;

use strict;
use POSIX qw(:sys_wait_h);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
use warnings;
use DDP;

sub allow_matrix_dim
{
	my ($mat_a, $mat_b)=@_;
	if ((ref($mat_a) ne 'ARRAY') or (ref($mat_b) ne 'ARRAY'))
    {
    	die 'Invalid date!\n';
    }
    my $size_m=$#{$mat_a->[0]};
    if (!(defined $mat_a->[$size_m]) or (defined $mat_a->[$size_m+1]))
    {
    	die 'wrong size of matrix';
    }
    if (!(defined $mat_b->[$size_m]) or (defined $mat_b->[$size_m+1]))
    {
    	die 'wrong size of matrix';
    }
    return $size_m+1;
}

sub multiply_m
{
	my ($mat_a, $mat_b, $row, $col, $dim)=@_;
	my $res;
	foreach my $i (0..$dim)
	{
		$res+= $mat_a->[$row]->[$i]*$mat_b->[$i]->[$col];
	}
	return $res;
}


sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];
    #...
	$| = 1;
	my @res;
    my ($r, $w);
    my ($r1, $w1);
	my @pids;
	my @res2;
	my @nums;
	my $pid;
    my $dim = allow_matrix_dim($mat_a, $mat_b);
    my $dim2=$dim*$dim;
    if ($max_child > $dim2)
    {
    	$max_child=$dim2;
    }
    my $ost=$dim2%$max_child;
	my $count=$dim2;
	my $k=($count-$ost)/$max_child;
	my $num;
	my $num1;
	my $x=0;
	my $y=0;
    foreach my $i (0..$max_child-1)
    {
    	pipe($r,$w);
    	pipe($r1, $w1);
   		if ($pid=fork())
   		{
   			close ($w1);
   			close ($r);
   			if ($ost >0)
   			{	
   				$count=$count-$k-1;
   				$num=$k+1;
   				$ost=$ost-1;
   			}
   			else 
   			{
	   			$num=$k;
   			}
   			print $w $num, "\n", $x, "\n" ,$y;
   			close ($w);
   			$num1=$num;
   			while ($num){
   				if ($y==$dim-1)
   				{
   					$y=0;
   					$x++;
   				}
   				else 
   				{
   					$y++;
   				}
   				$num--;
   			}
   			push @pids, $pid;
   			push @nums, $num1;
   			my $k=0;
   			while (<$r1>)
   			{
   				chomp;
   				$res2[$i][$k]=$_;
   				$k++;
   			}
   			close ($r1);	
      }
      else
      {
        die "Can't fork!\n" unless defined $pid;
        close ($w);
        my $count1;
        my @cxy;
        while (<$r>)
        {
          chomp;
          push @cxy, $_;
        }
        close ($r);
        $count1 = $cxy[0];
        $x=$cxy[1];
        $y=$cxy[2];
        my @res1;
        while ($count1 > 0)
        {
          $count1=$count1-1;
          my $str=multiply_m ($mat_a, $mat_b, $x, $y, $dim-1);
          if ($y==$dim-1)
          {
            $y=0;
            $x++;
          }
          else 
          {
            $y++;
          }
          push @res1, $str;
        }
        close ($r1);
        foreach my $i (@res1)
        {
          print $w1 $i, "\n";
        }
        close ($w1);
        exit;
      }
    }
    $x=0;
    $y=0;
    foreach my $i (0..$max_child-1)
    {
      foreach my $j (0..$nums[$i]-1)
      {
        $res[$x][$y]=$res2[$i][$j];
        if ($y==$dim-1)
        {
          $y=0;
          $x++;
        }
        else 
        {
          $y++;
        }
      }
    }
    foreach $pid (@pids)
    {
   		waitpid($pid,0);
    }
    $res=\@res;
    return $res;
}
1;
