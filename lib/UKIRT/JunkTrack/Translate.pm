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

UKIRT::JunkTrack::Translate - Pass XML through the UKIRT translator

=cut

package UKIRT::JunkTrack::Translate;

use strict;

use base 'Exporter';
our @EXPORT_OK = qw/translate/;

our $VERSION = '0.001';

=head1 SUBROUTINES

=over 4

=item translate

Translate the given XML file.

    $queue_file = translate($filename);

=cut

our $TRANSLATOR = '/jac_sw/omp/QT/bin/UkirtTranslator.csh';

sub translate {
    my $filename = shift;

    open XR, '-|', "$TRANSLATOR -queue -i $filename";

    my $queue = undef;

    while (my $line = <XR>) {
        $queue = $1
            if $line =~ /^Wrote queue file: ([^\s]+\.xml)/
    }

    close XR;

    die 'The translator does not seem to have written a queue file'
        unless defined $queue;

    return $queue;
}

1;

__END__

=back

=cut
