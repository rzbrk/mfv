#!/usr/bin/perl

use strict;
use warnings;


# Check if program was invoked correctly
if ($#ARGV != 0) {
    print "\nUsage: mfv.pl \"+49 123 456789\"\n";
    exit;
}

# Check if argument is valid phone number
if ($ARGV[0]=~m/^[+]*[0-9-\(\)\/ #\*]*$/) {
    my $phone = $ARGV[0];

    # Remove all special characters
    $phone =~ s/[-\/\(\)\s]//g;
    $phone =~ s/[+]/00/g;

    # Play tones
    tones($phone);
} else {
    print "$ARGV[0] is no valid phone number!\n";
}

sub tones {
    my $phone = shift;

    my %t = ("1" => "sin 697 sin 1209",
             "2" => "sin 697 sin 1336",
             "3" => "sin 697 sin 1477",
             "4" => "sin 770 sin 1209",
             "5" => "sin 770 sin 1336",
             "6" => "sin 770 sin 1477",
             "7" => "sin 852 sin 1209",
             "8" => "sin 852 sin 1336",
             "9" => "sin 852 sin 1477",
             "*" => "sin 941 sin 1209",
             "0" => "sin 941 sin 1336",
             "#" => "sin 941 sin 1477");
    print "$phone\n";

    while($phone =~ /(.)/g) {
        print "$1";
        system "play -n  synth 0.15 $t{$1} > /dev/null 2>&1";
        sleep 0.05;
    }
    print "\n";
}
