MFV -- Plays DTMF (dual-tone multi-freq signal) for phone numbers.

Usage:

    mfv.pl [OPT] [NUMBER]

Command Line Options:
    --aliases=[FILE]        Specify alias file. Default: ./aliases
    --tone-length=[LEN]     Length of DTMF tones in seconds. Default: 0.2s.
    --pause=[LEN]           Length of pause between tones in seconds.
                            Default: 0.05s.
    --fade=[LEN]            Length of fading in/out in seconds. fade=0
                            disables fading. 2 times the fading time shall
                            never exceed the total length of the tones.
                            Default: 0.02s.
    --help                  Shows this help message.

Argument:

Argument is a series of digits including the characters * and # and blanks.
If the number contains blanks, put the number in quotation marks. Following
formats are supported:

    123456
    "01234-123456"
    "01234/123456"
    "(01234) 123456"
    "01234/123-456"
    "+49 123 456789"
    "0049 123 456789"
    "01234-123-456#3#"

Examples:
    mfv.pl "+49 123 456789"     Play DTMF for given phone number
    mfv.pl "name"               Search phone number in alias file
    mfv.pl --help               Output help message

MFV Copyright (C) 2015 Jan Grosser <email@jan-grosser.de>
This program comes with ABSOLUTELY NO WARRANTY. This is free software, and
you are welcome to redistribute it under under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3
of the License, or any later version.

For more information visit <https://github.com/rzbrk/mfv>.

