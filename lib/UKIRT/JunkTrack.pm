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

# Time taken to prepare the observation, place it on the queue, and
# start observing it.
our $TIME_TO_PREPARE = new DateTime::Duration(seconds => 10);

# Time taken between instructing the queue to start and the observation
# actually beginning.  (Also included in TIME_TO_PREPARE.)
our $TIME_TO_START = new DateTime::Duration(seconds => 1);

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

    my $self = {
        model => new UKIRT::JunkTrack::Model($opt{'data'}),
        msb => $opt{'msb'},
        duration => $opt{'duration'},
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
    my $dt_obs = $dt_now + $TIME_TO_PREPARE;
    my $dt_start = $dt_obs - $TIME_TO_START;

    my (undef, undef, $root) = File::Spec->splitpath($self->{'msb'});
    my $filename_out = File::Spec->catfile($MSB_DIR,
        $dt_now->strftime('%Y%m%d-%H%M%S_') . $root);

    print STDERR "Editing XML for $dt_obs as $filename_out\n";

    edit_xml($self->{'msb'}, $filename_out, $self->{'model'}, $dt_obs,
             $self->{'duration'});

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
