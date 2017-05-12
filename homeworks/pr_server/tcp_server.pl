#!/usr/bin/env perl

use warnings;
use strict;
use AnyEvent;
use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;
use DDP;

my $cv=AE::cv;

$SIG{INT}=sub {
	#printf "GoodBye!\n";
	$cv->send();
};

my %connect;

#printf "Hello!\n";

tcp_server '127.0.0.1', 1234, sub {
	my ($fh, $host, $port)=@_;
	$cv->send($!) unless defined $fh;
	my $peer = join(':', $host,$port);
	#printf "Your client connected to: $peer\n";
	my $h = AnyEvent::Handle->new(
		fh => $fh,
	);
	$h->on_error (sub {
		my ($handle, $fatal, $message)=@_;
		#printf "I have bad news: $message \n";
		$h->destroy;
		delete $connect{$handle};
		#$cv->send();
	});
	$h->on_eof (sub {
		my $handle=shift;
		#printf "Bye!\n";
		$h->destroy;
		delete $connect{$handle};
	});

	$h->on_read (sub {
		my $handle=shift;
		#printf "Uhhu! I like read! ($handle)\n";
		$handle -> push_read ( line => sub {
			my ($handle, $line)=@_;
			#printf "Reading $line\n";
			if ($line =~ /^URL\s(.*)$/)
			{
				#printf "You give me URL: $1\n";
				$handle->push_write("OK\n");
				$connect{$peer}=$1;
			}
			elsif ($line eq 'HEAD')
			{
				#printf "You ask me give you the HEAD\n";
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
							my $head = $key.': '.$headers->{$key}."\n";
							push @array, $key.': '.$headers->{$key}."\n";
							$length += length $head;
						}
						$handle->push_write("OK $length\n");
						#printf "I say, that your HEAD: OK $length\n";
						foreach (@array)
						{
							$handle->push_write($_);
							#printf "$_\n";
						}
					};
				}
				else
				{
					#printf "HEAD: You don't give me URL before:(\n";
					$handle->push_write("where URL?\n");
				}
			}
			elsif ($line eq 'GET')
			{
				#printf "You ask me give you the GET\n";
				if ($connect{$peer})
				{
					http_get
					$connect{$peer},
					sub {
						my $data = shift;
						my $length = length $data;
						$handle->push_write("OK $length\n");
						#printf "I say, that your GET: OK $length\n";
						$handle->push_write($data);
						#printf "$data\n";
					};	
				}
				else
				{
					#printf "GET: You don't give me URL before:(\n";
					$handle->push_write("where URL?\n");
				}
			}
			elsif ($line eq 'FIN')
			{
				#printf "You ask me give you the FIN\n";
				$handle->push_write("OK\n");
				delete $connect{$handle};
				$handle->destroy;
				#printf "FIN: OK\n";
			}
			else
			{
				#printf "You ask for garbage\n";
				$handle->push_write("it's not a normal command!\n");
			}
		});
	});
};

$cv->recv;

1;