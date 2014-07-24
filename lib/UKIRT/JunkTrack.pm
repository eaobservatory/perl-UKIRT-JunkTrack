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

UKIRT::JunkTrack - Utility for observing space junk

=head1 DESCRIPTION

This module brings together the components of the UKIRT::JunkTrack
package into a class which can be used to automate the preparation
of observations.

=cut

package UKIRT::JunkTrack;

use DateTime;
use DateTime::Duration;
use File::Spec;
use Time::HiRes qw/usleep/;

use UKIRT::JunkTrack::Model;
use UKIRT::JunkTrack::EditXML qw/edit_xml/;
use UKIRT::JunkTrack::Translate qw/translate/;
use UKIRT::JunkTrack::Queue qw/queue_load queue_start/;

use strict;

our $VERSION = '0.001';

# Time taken to prepare the observation and place it on the queue.
our $TIME_TO_PREPARE = new DateTime::Duration(seconds => 10);

# Time taken between instructing the queue to start and the observation
# actually beginning.  (No longer included in TIME_TO_PREPARE.)
our $TIME_TO_START = new DateTime::Duration(seconds => 5);

# Directory in which to write edited MSBs.
our $MSB_DIR = '/jac_sw/itsroot/nasaFiles/edited';

=head1 METHODS

=over 4

=item new

    my $tracker = new UKIRT::JunkTrack(
        data => $tracking_filename,
        msb => $xml_filename,
        duration => $obs_dur_seconds,
    );

=cut

sub new {
    my $class = shift;
    my %opt = @_;

    die 'Data file not specified' unless exists $opt{'data'};
    die 'MSB XML file not specified' unless exists $opt{'msb'};
    die 'Observation duration not specified' unless exists $opt{'duration'};

    # Use first part of filename as the target name.  Requested by
    # THK 3/26/14.
    my (undef, undef, $data_basename) = File::Spec->splitpath($opt{'data'});
    my ($target, undef) = split /\./, $data_basename, 2;

    my $self = {
        model => new UKIRT::JunkTrack::Model($opt{'data'}),
        msb => $opt{'msb'},
        duration => $opt{'duration'},
        target => $target,
    };

    $class = ref($class) if ref($class);
    return bless $self, $class;
}

=item observe

Prepares the observation to be performed a short time in the future (specified
by the $TIME_TO_PREPARE variable).  Then waits until it is time to tell
the queue to start (defined by $TIME_TO_START) before doing so and returning.

    $tracker->observe();

=cut

sub observe {
    my $self = shift;

    my $dt_now = DateTime->now(time_zone => 'UTC');
    my $dt_start = $dt_now + $TIME_TO_PREPARE;
    my $dt_obs = $dt_start + $TIME_TO_START;

    my (undef, undef, $root) = File::Spec->splitpath($self->{'msb'});
    my $filename_out = File::Spec->catfile($MSB_DIR,
        $dt_now->strftime('%Y%m%d-%H%M%S_') . $root);

    print STDERR "Editing XML for $dt_obs as $filename_out\n";

    edit_xml($self->{'msb'}, $filename_out, $self->{'model'}, $dt_obs,
             $self->{'duration'}, $self->{'target'});

    print STDERR "Translating XML $filename_out file\n";

    my $queue_file = translate($filename_out);

    print STDERR "Loading queue file $queue_file\n";

    queue_load($queue_file);

    print STDERR "Waiting until it is time to start the queue\n";

    usleep(50) while DateTime->now(time_zone => 'UTC') < $dt_start;

    print STDERR "Starting the queue\n";

    queue_start();
}

1;

__END__

=back

=cut
