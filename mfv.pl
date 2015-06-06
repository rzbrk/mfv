#!/usr/bin/perl

use strict;
use warnings;
use Config::Simple ('-lc');

# Define constants
my $aliases = "./aliases";                  # Aliases file
my $tone_len = 0.20;                        # Length of tones
my $pause = 0.05;                           # Pause between tones
my $fade = 0.02;                            # Fade in/out times (zero for no
                                            # fading)
my $err_msg = "\"$ARGV[0]\" is neither a valid phone number nor an alias!\nCall \"$0 --help\" for help.\n\n";

# Check if program was invoked correctly
if ($#ARGV != 0) {
    help();
    exit;
}

# Check if user wants help
if ($ARGV[0] =~ m/^[-]{0,2}(help|h|\?)$/i) {
    help();
    exit;
}

# Initialize variable for phone number
my $phone;

# Check if argument is valid phone number
if (is_phone($ARGV[0])) {
    $phone = $ARGV[0];
    $phone = clean_phone($phone);           # Remove special characters
    tones($phone,$tone_len,$pause,$fade);   # Play tones
} elsif (in_aliases($ARGV[0], $aliases) ne "") {
    $phone = in_aliases($ARGV[0], $aliases);
    if (is_phone($phone)) {
        $phone = clean_phone($phone);       # Remove special characters
        tones($phone,$tone_len,$pause,$fade);   # Play tones
    } else {
        print $err_msg;
    }
} else {
    print $err_msg;
}

###############################################################################
###############################################################################

#
# Print help message.
#
sub help {
    print "
MFV -- Plays DTMF (dual-tone multi-freq signal) for phone numbers.\n
Usage:\n
    $0 \"+49 123 456789\"     play DTMF for given phone number
    $0 \"alias\"              search phone number in alias file
    $0 --help               output help message\n
MFV is free software licenced under GNU General Public license v3.\n";
}

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
    my $len = shift;
    my $pause = shift;
    my $fade = shift;

    my %t = ("1" => "-n synth $len sin 697 sin 1209 fade $fade $len $fade",
             "2" => "-n synth $len sin 697 sin 1336 fade $fade $len $fade",
             "3" => "-n synth $len sin 697 sin 1477 fade $fade $len $fade",
             "4" => "-n synth $len sin 770 sin 1209 fade $fade $len $fade",
             "5" => "-n synth $len sin 770 sin 1336 fade $fade $len $fade",
             "6" => "-n synth $len sin 770 sin 1477 fade $fade $len $fade",
             "7" => "-n synth $len sin 852 sin 1209 fade $fade $len $fade",
             "8" => "-n synth $len sin 852 sin 1336 fade $fade $len $fade",
             "9" => "-n synth $len sin 852 sin 1477 fade $fade $len $fade",
             "*" => "-n synth $len sin 941 sin 1209 fade $fade $len $fade",
             "0" => "-n synth $len sin 941 sin 1336 fade $fade $len $fade",
             "#" => "-n synth $len sin 941 sin 1477 fade $fade $len $fade");

    # Play the tones. If number or character cannot be found in the hast defined
    # above, simply skip it.
    print "Playing: ";
    while($phone =~ /(.)/g) {
        if (exists($t{$1})) {
            print "$1";
            system "play $t{$1} > /dev/null 2>&1";
            sleep $pause;
        }
    }
    print "\n";
}

#
# Retrieve phone number for search string in aliases file, if defined. If not
# defined, the routine returns an empty string.
#
sub in_aliases {
    my $string = shift;     # String to look in aliases file
    my $aliases = shift;    # Aliases file

    # Initialize return value
    my $ret = "";

    # First check, if aliases file exists and is readable
    if (-r $aliases) {
        # Retrieve phone number for alias in $string if defined. If not, return
        # empty string.
        my $cfg = new Config::Simple($aliases);
        $ret = $cfg->param($string) or $ret = "";
    }
    return $ret;
}

