#!/usr/bin/perl

use strict;
use warnings;
our $VERSION = 1.0;
use DDP;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
#report($parsed_data);
exit;

sub parse_file {
    my $file = shift;

    # you can put your code here
    my %hash_ip;

    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file

        $log_line =~ /^(\d+\.\d+\.\d+\.\d+)\s+\[[^\]]*\]\s+"[^"]*"\s+(\d+)\s+(\d+)\s+"[^"]*"\s+"[^"]*"\s+"(\d+.\d+)"$/;
        #$1 ip
        #$2 status code
        #$3 byte
        #$4 k
        if (exists $hash_ip{$1})
        {
            @{$hash_ip{$1}}[0]=@{$hash_ip{$1}}[0]+1;
            @{$hash_ip{$1}}[1]=@{$hash_ip{$1}}[1]+$3*$4;
            if (exists @{$hash_ip{$1}}[2]->{$2})
            {
                @{$hash_ip{$1}}[2]->{$2}=@{$hash_ip{$1}}[2]->{$2}+1; #??? +$3*$4
            }
            else
            {
                @{$hash_ip{$1}}[2]->{$2}=1; #??? $3*$4
            }

        }
        else
        {
            my %hash_stat;
            $hash_stat{$2}=1; #??? $3*$4;
            my @new_arr=();
            $new_arr[0]=1;
            $new_arr[1]=$3*$4;
            $new_arr[2]=\%hash_stat;
            $hash_ip{$1}=\@new_arr;
        }
    }
    close $fd;

    p %hash_ip;

    $result=\%hash_ip;
    # you can put your code here

    return $result;
}

#sub report {
 #   my $result = shift;

    # you can put your code here

#}
