#!/usr/bin/perl

#    MFV -- Generate dual-tone multi-frequency sounds with perl and sox
#    Copyright (C) 2015 Jan Grosser
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Config::Simple ('-lc');
use Getopt::Long qw(:config no_getopt_compat);

# Define constants
my $err_msg = "\"$ARGV[0]\" is neither a valid phone number nor an alias!\nCall \"$0 --help\" for help.\n\n";
my $aliases = "./aliases";                  # Aliases file
my $tone_len = 0.20;                        # Length of tones
my $pause = 0.05;                           # Pause between tones
my $fade = 0.02;                            # Fade in/out times (zero for no
                                            # fading)
my $help=0;

# Read in command line options
GetOptions (
    "aliases|a=s"       => \$aliases,
    "tone-length|l=f"   => \$tone_len,
    "pause|p=f"         => \$pause,
    "fade|f=f"          => \$fade,
    "help|h|?"          => \$help,
);

# Check whether fading time is too long. Fading shall never exceed 25% of the
# length of the tone
if (2*$fade > 0.25*$tone_len) {
    print "Error: fading time is too long with respect to tone length\n";
    exit;
}

# Check if program was invoked correctly
if ($#ARGV != 0) {
    help();
    exit;
}

# Check if user wants help
if ($help) {
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
    $0 [OPT] [NUMBER]\n
Command Line Options:\n
    --aliases=[FILE]        Specify alias file. Default: ./aliases
    --tone-length=[LEN]     Length of DTMF tones in seconds. Default: 0.2s.
    --pause=[LEN]           Length of pause between tones in seconds.
                            Default: 0.05s.
    --fade=[LEN]            Length of fading in/out in seconds. fade=0
                            disables fading. 2 times the fading time shall
                            never exceed the total length of the tones.
                            Default: 0.02s.
    --help                  Shows this help message.\n
Argument:\n
Argument is a series of digits including the characters * and # and blanks.
If the number contains blanks, put the number in quotation marks. Following
formats are supported:\n
    123456
    \"01234-123456\"
    \"01234/123456\"
    \"(01234) 123456\"
    \"01234/123-456\"
    \"+49 123 456789\"
    \"0049 123 456789\"
    \"01234-123-456#3#\"\n
Examples:\n
    $0 \"+49 123 456789\"     Play DTMF for given phone number
    $0 \"name\"               Search phone number in alias file
    $0 --help               Output help message\n
MFV Copyright (C) 2015 Jan Grosser <email\@jan-grosser.de>
This program comes with ABSOLUTELY NO WARRANTY. This is free software, and
you are welcome to redistribute it under under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3
of the License, or any later version.\n
For more information visit <https://github.com/rzbrk/mfv>.\n";
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

    my %t = ("1" => "-n synth $len sin 697 sin 1209 fade $fade $len $fade channels 1",
             "2" => "-n synth $len sin 697 sin 1336 fade $fade $len $fade channels 1",
             "3" => "-n synth $len sin 697 sin 1477 fade $fade $len $fade channels 1",
             "4" => "-n synth $len sin 770 sin 1209 fade $fade $len $fade channels 1",
             "5" => "-n synth $len sin 770 sin 1336 fade $fade $len $fade channels 1",
             "6" => "-n synth $len sin 770 sin 1477 fade $fade $len $fade channels 1",
             "7" => "-n synth $len sin 852 sin 1209 fade $fade $len $fade channels 1",
             "8" => "-n synth $len sin 852 sin 1336 fade $fade $len $fade channels 1",
             "9" => "-n synth $len sin 852 sin 1477 fade $fade $len $fade channels 1",
             "*" => "-n synth $len sin 941 sin 1209 fade $fade $len $fade channels 1",
             "0" => "-n synth $len sin 941 sin 1336 fade $fade $len $fade channels 1",
             "#" => "-n synth $len sin 941 sin 1477 fade $fade $len $fade channels 1");

    # Play the tones. If number or character cannot be found in the hash defined
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

