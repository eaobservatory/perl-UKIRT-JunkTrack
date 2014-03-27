=head1 NAME

UKIRT::JunkTrack::Translate - Pass XML through the UKIRT translator

=cut

package UKIRT::JunkTrack::Translate;

use strict;

use base 'Exporter';
our @EXPORT_OK = qw/translate/;

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
