#!/usr/bin/perl

use strict;
use warnings;
our $VERSION = 1.0;
use DDP;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my $all='total';
    # you can put your code here
    my %hash_ip;
    my @new_arr_1=();
    my %hash_stat_1=(
                    200 => 0,
                    301 => 0,
                    302 => 0,
                    400 => 0,
                    403 => 0,
                    404 => 0,
                    408 => 0,
                    414 => 0,
                    499 => 0,
                    500 => 0
    );
    my %hash_time_1=();
    $new_arr_1[0]=0;
    $new_arr_1[1]=0;
    $new_arr_1[2]=\%hash_stat_1;
    $new_arr_1[3]=\%hash_time_1;
    $new_arr_1[4]=0;
    $hash_ip{$all}=\@new_arr_1;

    my $fd;
    if ($file =~ /\.bz2$/) {
        open $fd, "-|", "bunzip2 < $file" or die "Can't open '$file' via bunzip2: $!";
    } else {
        open $fd, "<", $file or die "Can't open '$file': $!";
    }

    my $result;
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file

        $log_line =~ /^((\d+\.){3}\d+)\s+\[([^:]*:\d+:\d+)[^\]]*\]\s+"[^"]*"\s+(\d+)\s+(\d+)\s+"[^"]*"\s+"[^"]*"\s+"(\d+.\d+)"$/;
        #                ip                    [ все, кроме ]
        #$1 ip
        #$3 time min
        #$4 status code
        #$5 byte
        #$6 k
        if ($1 and $3 and $6 and $4 and $5)
        {
            ${$hash_ip{$1}}[0]+=1;
            ${$hash_ip{$all}}[0]+=1;
            if ($4 == 200)
            {
                ${$hash_ip{$1}}[1]+=$5*$6;    
                ${$hash_ip{$all}}[1]+=$6*$5;
            }
            else
            {
                ${$hash_ip{$1}}[1]+=0;
            }
            ${$hash_ip{$1}}[2]->{$4}+=$5;
            ${$hash_ip{$all}}[2]->{$4}+=$5;
            for my $i ($1,$all)  
            {
                if (${$hash_ip{$i}}[3]->{$3})
                {
                    ${$hash_ip{$i}}[3]->{$3}++; 
                    ${$hash_ip{$i}}[4]+=0;
                }
                else
                {
                    ${$hash_ip{$i}}[3]->{$3}=1;
                    ${$hash_ip{$i}}[4]++;
                }
            }
        }
    }
    close $fd;

    #p %hash_ip;

    $result=\%hash_ip;
    # you can put your code here
    return $result;
}

sub report {
    my $result = shift;

    # you can put your code here
    my @arr_code=(200, 301, 302, 400, 403, 404, 408, 414, 499, 500);
    #p @arr_code;
    my @arr=();
    my $key1=0;
    for (1..11)
    {
        my $value1=0;
        while (my($key,$value)=each (%{$result}))
        {
            if ($value->[0]>$value1)
            {
                $value1=$value->[0];
                $key1=$key;
            }
        }
        push @arr, $key1;
        push @arr, ($result)->{$key1};
        delete $result->{$key1};
    }
    #p @arr;
    printf ("IP\tcount\tavg\tdata");
    for (@arr_code)
    {
        printf ("\t%d", $_);
    }
    printf "\n";
    my $i=0;
    while ($i<21)
    {
        printf "$arr[$i]";
        printf "\t$arr[$i+1][0]";
        printf "\t%.2f", (($arr[$i+1])->[0])/($arr[$i+1][4]);
        printf "\t%.0f", (($arr[$i+1])->[1])/1024;
        for (@arr_code)
        {
            if ($arr[$i+1][2]->{$_})
            {
                printf "\t%.0f", ($arr[$i+1]->[2])->{$_}/1024;
            }
            else
            {
                printf "\t0";
            }
        }
        printf "\n";
        $i+=2;
    }
}1
