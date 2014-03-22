=head1 NAME

UKIRT::JunkTrack::Parse - Parse space junk coordinate files

=cut

package UKIRT::JunkTrack::Parse;

use strict;

use DateTime;
use IO::File;

use base 'Exporter';
our @EXPORT_OK = qw/parse_file/;

use Data::Dumper;

=head1 SUBROUTINES

=over 4

=item parse_file

Parses a file and returns a reference to an array of datetime, RA, Dec
arrays.

    my $record = parse_file($filename)

=cut

sub parse_file {
    my $filename = shift;

    my $year = undef;
    my @record;

    my $fh = new IO::File($filename, 'r');

    while (<$fh>) {
        $year = $1 if /^#uk +(\d\d\d\d)-/;

        # Skip headers and blank lines.
        next if /^#/;
        next if /^\s*DecUT/;
        next unless $_;

        # Require the year to be found before parsing data.
        die 'Junk tracking data found before date header' unless defined $year;

        # Extract the columns we need.
        my (undef, $hh, $mm, $sec, undef, undef, $ra, $dec, undef, undef, undef, undef, undef, undef,
            undef, undef, undef, undef, undef, $doy, undef, undef, undef, undef, undef, undef) = split;

        my $dt = new DateTime(
            year => $year,
            month => 1,
            day => 1,
            hour => 0,
            minute => 0,
            second => 0,
            time_zone => 'UTC',
        );

        $dt->add_duration(new DateTime::Duration(
            days => $doy - 1,
            hours => $hh,
            minutes => $mm,
            seconds => $sec,
        ));

        push @record, [$dt, $ra, $dec];
    }

    $fh->close();

    # Check that some records were found.
    die 'No junk tracking data records found' unless scalar @record;

    # Print a message to STDERR
    print STDERR sprintf("Read %i junk tracking records: %s -- %s\n",
        (scalar @record),
        $record[0]->[0],
        $record[-1]->[0],
    );

    return \@record;
}

1;

__END__

=back

=cut
