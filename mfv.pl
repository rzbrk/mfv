#!/usr/bin/perl

use strict;
use warnings;


# Check if program was invoked correctly
if ($#ARGV != 0) {
    print "\nUsage: mfv.pl \"+49 123 456789\"\n";
    exit;
}

# Check if argument is valid phone number
if (is_phone($ARGV[0])) {
    my $phone = $ARGV[0];

    # Remove all special characters
    $phone = clean_phone($phone);

    # Play tones
    tones($phone);
} else {
    print "$ARGV[0] is no valid phone number!\n";
}

###############################################################################
###############################################################################

#
# Cleans the string holding a phone number by removing all special characters
# (like brackets, blanks and minus signs) and replaces "+" by "00".
#
sub clean_phone {
    my $phone = shift;

    # Remove all special characters
    $phone =~ s/[-\/\(\)\s]//g;
    $phone =~ s/[+]/00/g;

    return $phone;
}

#
# Checks if string is a valid phone number and returns 1 if this is the case.
# Otherwise, it returns 0.
#
sub is_phone {
    my $string = shift;

    my $ret = 0;
    if ($string =~m/^[+]*[0-9-\(\)\/ #\*]*$/) {
        $ret = 1;
    }
    return $ret;
}

# 
# Converts series of numbers (0...9) and "*" and "#" to dual-tone
# multi-frequency signals. 
#
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

    # Play the tones. If number or character cannot be found in the hast defined
    # above, simply skip it.
    print "Playing: ";
    while($phone =~ /(.)/g) {
        if (exists($t{$1})) {
            print "$1";
            system "play -n  synth 0.15 $t{$1} > /dev/null 2>&1";
            sleep 0.05;
        }
    }
    print "\n";
}
