=head1 NAME

UKIRT::JunkTrack::Queue - Module for interacting with the queue

=head1 DESCRIPTION

This module includes a few routines for interacting with the
queue.  It is assumed that DRAMA has already been initialized.

=cut

package UKIRT::JunkTrack::Queue;

use strict;

use DRAMA;
use Sds;

use base 'Exporter';
our @EXPORT_OK = qw/queue_load queue_start/;

=head1 SUBROUTINES


=head1 SUBROUTINES

=over 4

=item queue_load

Clears the queue and loads the given file into it.

    queue_load($queue_file);

=cut

sub queue_load {
    my $queue_file = shift;

    my $status = new DRAMA::Status;
    my $arg = Arg->Create();
    $arg->PutString("Argument1", $queue_file, $status);

    obeyw('OCSQUEUE', 'LOADQ', $arg, {
         -success => sub {
            print STDERR "OCSQUEUE LOADQ successful\n";
        },
        -complete => sub {
            print STDERR "OCSQUEUE LOADQ complete\n";
        },
        -error => sub {
            print STDERR "ERROR: OCSQUEUE LOADQ error\n";
        },
    });
}

=item queue_start

Instructs the queue to start.

    queue_start();

=cut

sub queue_start {
    obeyw('OCSQUEUE', 'STARTQ', {
        -success => sub {
            print STDERR "OCSQUEUE STARTQ successful\n";
        },
        -complete => sub {
            print STDERR "OCSQUEUE STARTQ complete\n";
        },
        -error => sub {
            print STDERR "ERROR: OCSQUEUE STARTQ error\n";
        },
    });
}

1;

__END__

=back

=cut
