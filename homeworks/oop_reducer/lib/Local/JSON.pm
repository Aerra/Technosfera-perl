package Local::Row::JSON;

use strict;
use warnings;
use DDP;
use parent 'Local::Row';
use JSON::XS;
use utf8;

sub new {
	my ($class, %params)=@_;
	my $json_xs = JSON::XS->new();
    $json_xs->utf8(1);
    my $log=eval {$json_xs->decode($params{str})};
    if ($log)
    {
    	$log = $json_xs->decode($params{str});
    	if (ref $log ne 'HASH')
    	{
    		return undef;
    	}
    }
    else
    {
    	return undef;
    }
    #my $res{log}=$log;
    return bless $log, $class;
}


1;