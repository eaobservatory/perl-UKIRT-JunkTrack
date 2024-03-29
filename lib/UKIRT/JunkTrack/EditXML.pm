# Copyright (C) 2014 Science and Technology Facilities Council.
# All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 NAME

UKIRT::JunkTrack::EditXML - Edit XML to insert new coordinates

=head1 NOTE

This module currently works by pattern-matching on the text serialization
of the "OT" XML.  It is therefore somewhat dependent on the format in which
the OT currently writes this.  Should this become a problem it would
be possible to have this module use a full XML parser instead.

=cut

package UKIRT::JunkTrack::EditXML;

use strict;

use IO::File;

use Astro::Coords;

use base 'Exporter';
our @EXPORT_OK = qw/edit_xml/;

our $VERSION = '0.001';

=head1 SUBROUTINES

=over 4

=item edit_xml

Rewrites the "OT" XML file C<$filename_in> as a file C<$filename_out> using
the L<UKIRT::JunkTrack::Model> object C<$model> to obtain coordinates.
For the first observation, the model is queried at time C<$dt>,
and after each observation, C<$obs_dur_sec> seconds are added to this
DateTime.

    edit_xml($filename_in, $filename_out, $model, $dt,
             $obs_dur_sec, $target_name);

The target names in the XML file are also replaced with the specified
target name.

The coordinates given by the model are assumed to be for the current date
rather than J2000.  Therefore the given datetime is used to form a
coordinate system "type" for Astro::Coords of the form J2014.268.

=cut

sub edit_xml {
    my $filename_in = shift;
    my $filename_out = shift;
    my $model = shift;
    my $dt = shift;
    my $obs_dur_sec = shift;
    my $target_name = shift;

    my $r = new IO::File($filename_in, 'r');
    die 'Failed to open template MSB XML file' unless defined $r;

    my $w = new IO::File($filename_out, 'w');
    die 'Failed to open output edited MSB XML file' unless defined $w;

    my $c1 = undef;
    my $c2 = undef;

    while (my $line = <$r>) {
        # Start of target coordinates?
        if ($line =~ /<spherSystem/) {
            my $type  = sprintf('J%.3f', $dt->year() +
                ($dt->day_of_year() / ($dt->is_leap_year() ? 366.0 : 365.0)));
            my ($ra, $dec) = $model->get_coords($dt);
            $dt->add(seconds => $obs_dur_sec);

            my $c = new Astro::Coords(
                name => "Target",
                ra   => $ra,
                dec  => $dec,
                type => $type,
                units=> 'deg',
            );

            ($ra, $dec) = $c->radec2000();

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

        # Target name?
        if ($line =~ /<targetName>/) {
            $line =~ s/<targetName>.*<\/targetName>/<targetName>$target_name<\/targetName>/;
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
