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

our $VERSION = '0.001';

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
