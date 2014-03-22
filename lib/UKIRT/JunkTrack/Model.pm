=head1 NAME

UKIRT::JunkTrack::Model - Handle space junk tracking data

=cut

package UKIRT::JunkTrack::Model;

use strict;

use DateTime;

use UKIRT::JunkTrack::Parse qw/parse_file/;

=head1 METHODS

=over 4

=item new

Constructs an object used to model the position of a piece of space junk.
When the object is constructed, the position records will be read from the
given file and stored in the object.

    my $jt = new UKIRT::JunkTrack::Model($filename);

=cut

sub new {
    my $class = shift;
    my $filename = shift;

    my $self = {
        record => parse_file($filename),
    };

    $class = ref($class) if ref($class);
    return bless $self, $class;
}

=item get_coords

Returns the co-ordinates of the piece of junk for a given datetime.  If the
datetime appears exactly in the set of records read from the file then the
co-ordinates in the matching record are returned.  Otherwise linear
interpolation is performed between the records before and after the datetime.
An error is raised if the specified datetime is outside the range described by
the available records.

    my ($ra, $dec) = $jt->get_coords($dt);

=cut

sub get_coords {
    my $self = shift;
    my $dt = shift;

    my $prev = undef;

    foreach my $rec (@{$self->{'record'}}) {
        my $rec_dt = $rec->[0];
        if ($dt == $rec_dt) {
            # Exact match, return coordinates directly.
            return ($rec->[1], $rec->[2]);
        }
        if ($dt < $rec_dt) {
            # Interpolate between $prev and $rec.
            die 'Junk coordinates requested before first time record'
                if (not defined $prev) or $dt < $prev->[0];

            # Calculate duration of interval between the previous record and
            # the current one.
            my $t0 = $rec_dt->subtract_datetime_absolute($prev->[0])->in_units('nanoseconds');

            # Calculate the duration of the interval between the previous
            # record and the requested datetime.
            my $t1 = $dt->subtract_datetime_absolute($prev->[0])->in_units('nanoseconds');

            # Fraction of interval.
            my $f = $t1 / $t0;

            my ($ra, $dec) = ($rec->[1], $rec->[2]);
            my ($prev_ra, $prev_dec) = ($prev->[1], $prev->[2]);

            return (
                $prev_ra + ($ra - $prev_ra) * $f,
                $prev_dec + ($dec - $prev_dec) * $f,
            );
        }

        $prev = $rec;
    }

    die 'Junk coordinates requested after last time record';
}

1;

__END__

=back

=cut
