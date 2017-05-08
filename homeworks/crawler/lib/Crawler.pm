package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;
use Data::Dumper;
use DDP;
use List::Util qw(max);
$AnyEvent::HTTP::MAX_PER_HOST = 100;

=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

Сбор с сайта всех ссылок на уникальные страницы

Входные данные:

$start_page - Ссылка с которой надо начать обход сайта

$parallel_factor - Значение фактора паралельности

Выходные данные:

$total_size - суммарный размер собранных ссылок в байтах

@top10_list - top-10 страниц отсортированный по размеру.

=cut
#sub craw {
#
#}

#


sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page or die "You must setup url parameter";
    $parallel_factor or die "You must setup parallel factor > 0";
    my $total_size = 0;
    my @top10_listkey;

    #............
    #Код crawler-а
    #............
    my $wq;
    my @url = ($start_page);
    my $maxurl=1000;
    my $ll;
    my %visit;
    my $cv = AE::cv;
    $cv->begin;
   	my $next; 
   	$next = sub {
   		if (scalar keys(%visit) >= $maxurl or !(@url))
   		{
   			$cv->end;
   			return;
   		}
   		$ll++;
   		my $page = shift @url;
   		$cv -> begin;
   		http_head
   		$page,
   		sub {
   			my ($data, $headers)=@_;
   			if ($headers->{Status} =~ /^2/) {
   				if ($headers->{"content-type"} =~ "text/html")
   				{
   					$cv -> begin;
   					http_get
   					$page,
   					sub {
   						$data = shift;
   						$visit{$page}=length $data;
   						$wq = Web::Query -> new ($data);
   						if ($wq)
   						{
   							$wq ->find('a') -> each (sub { my $k=$_[1]->attr('href'); 
   											my $base= URI->new($page);
   											my $uri=URI->new_abs($k,$base);
   											push @url, $uri unless (defined $visit{$uri} && !($uri=~"^$start_page"));});
   						}
   						my $count = $#url+1 < $parallel_factor ? $#url+1 : $parallel_factor;
   						$next->() while ($ll<=$count); 
   						$ll--;
   						$cv->end;
   						return;
   					};
   				}
   				$cv->end;
   			}
   			else {
   				print "error, $headers->{Status} $headers->{Reason}\n";
   				$cv->end;
   			}
   		};
   	};
   	$next->();
    $cv->end;
    $cv->recv;
    my $count=scalar keys %visit;
    if ($count <= $maxurl)
    {
    	for my $key (keys %visit)
    	{
    		$total_size+=$visit{$key};
    	}
    }
    else 
    {
    	for my $key ((sort {$visit{$a} <=> $visit{$b}} keys %visit)[1..$count-$maxurl])
    	{
    		delete $visit{$key};
    	}
    	for my $key (keys %visit)
    	{
    		$total_size+=$visit{$key};
    	}
    }
    @top10_listkey=(sort {$visit{$b} <=> $visit{$a}} keys %visit) [0..9];
    return $total_size, @top10_listkey;
}

1;
