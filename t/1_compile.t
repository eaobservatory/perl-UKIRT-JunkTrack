use Test::More tests => 6;

use strict;

foreach (qw/UKIRT::JunkTrack
            UKIRT::JunkTrack::Parse
            UKIRT::JunkTrack::Model
            UKIRT::JunkTrack::EditXML
            UKIRT::JunkTrack::Translate
            UKIRT::JunkTrack::Queue/) {
    if (my $pid = fork) {
       waitpid($pid, 0);
       ok(!$?, $_);
    }
    else {
        die 'fork failed' unless defined $pid;
        eval "use $_;";
        die if $@;
        exit;
    }
}

