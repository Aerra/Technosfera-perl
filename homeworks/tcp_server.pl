#!/usr/bin/env perl

use warnings;
use strict;
use AnyEvent;
use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;
use DDP;
use feature qw(say);

my $cv=AE::cv;

$SIG{INT}=sub {
	$cv->send();
};

my %connect;

printf "Good!\n";

tcp_server '127.0.0.1', 1234, sub {
	printf "Good1\n";
	my ($fh, $host, $port)=@_ or $cv->send($!);
	my $peer = join(':', $host,$port);
	printf "$peer\n";
	my $h = AnyEvent::Handle->new(
		fh => $fh,
	);
	$h->on_error (sub {
		my ($handle, $fatal, $message)=@_;
		$h->destroy;
		delete $connect{$handle};
		#$cv->send();
	});
	$h->on_eof (sub {
		my $handle=shift;
		$h->destroy;
		delete $connect{$handle};
	});

	$h->on_read (sub {
		my $handle=shift;
		$handle -> push_read ( line => sub {
			printf "In read\n";
			my ($handle, $line)=@_;
			printf "$line\n";
			if ($line =~ /^URL\s(.*)$/)
			{
				printf "In URL\n";
				$handle->push_write("OK\n");
				$connect{$peer}=$1;
				printf "$connect{$peer}";
			}
			elsif ($line eq 'HEAD')
			{
				printf "In HEAD\n";
				if ($connect{$peer})
				{
					http_head
					$connect{$peer},
					sub {
						my ($data, $headers)=@_;
						my @array;
						my $length=0;
						foreach my $key (keys %{$headers})
						{
							push @array, $key.': '.$headers->{$key}."\n";
							$length += $key.': '.$headers->{$key}."\n";
						}
						$handle->push_write("OK $length\n");
						foreach (@array)
						{
							$handle->push_write($_);
						}
					};
				}
				else
				{
					$handle->push_write("where URL?\n");
				}
			}
			elsif ($line eq 'GET')
			{
				if ($connect{$peer})
				{
					http_get
					$connect{$peer},
					sub {
						my $data = shift;
						my $length = length $data;
						$handle->push_write("OK $length\n");
						$handle->push_write($data);
					};	
				}
				else
				{
					$handle->push_write("where URL?\n");
				}
			}
			elsif ($line eq 'FIN')
			{
				$handle->push_write("OK\n");
				delete $connect{$handle};
				$handle->destroy;
			}
			else
			{
				$handle->push_write("it's not a normal command!\n");
			}
		});
	});
};

$cv->recv;

1;