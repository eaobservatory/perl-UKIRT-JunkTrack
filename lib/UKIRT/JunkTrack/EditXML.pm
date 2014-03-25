=head1 NAME

UKIRT::JunkTrack::EditXML - Edit XML to insert new coordinates

=cut

package UKIRT::JunkTrack::EditXML;

use strict;

use IO::File;

use Astro::Coords::Angle;
use Astro::Coords::Angle::Hour;

use base 'Exporter';
our @EXPORT_OK = qw/edit_xml/;

=head1 SUBROUTINES

=over 4

=item edit_xml

Rewrites the "OT" XML file C<$filename_in> as a file C<$filename_out> using
the L<UKIRT::JunkTrack::Model> object C<$model> to obtain coordinates.
For the first observation, the model is queried at time C<$dt>,
and after each observation, C<$obs_dur_sec> seconds are added to this
DateTime.

    edit_xml($filename_in, $filename_out, $model, $dt, $obs_dur_sec);

=cut

sub edit_xml {
    my $filename_in = shift;
    my $filename_out = shift;
    my $model = shift;
    my $dt = shift;
    my $obs_dur_sec = shift;

    my $r = new IO::File($filename_in, 'r');
    my $w = new IO::File($filename_out, 'w');

    my $c1 = undef;
    my $c2 = undef;

    while (my $line = <$r>) {
        # Start of target coordinates?
        if ($line =~ /<spherSystem/) {
            my ($ra, $dec) = $model->get_coords($dt);
            $dt->add(seconds => $obs_dur_sec);

            $ra = new Astro::Coords::Angle::Hour($ra, units => 'deg');
            $dec = new Astro::Coords::Angle($dec, units => 'deg');

            $c1 = $ra->string();
            $c2 = $dec->string();
        }

        # C1?
        if ($line =~ /<c1/) {
            $line =~ s/<c1>.*<\/c1>/<c1>$c1<\/c1>/;
        }

        # C2?
        if ($line =~ /<c2/) {
            $line =~ s/<c2>.*<\/c2>/<c2>$c2<\/c2>/;
        }

        print $w $line;
    }

    $r->close();
    $w->close();
}

1;

__END__

=back

=cut
