Example usage:

    observe_junk \
        --data /jac_sw/itsroot/nasaFiles/uk1920140837566.txt2.mlb \
        --msb /jac_sw/itsroot/nasaFiles/u14alm15_27566.xml \
        --duration 340

Configuration inside Perl modules:

    Timing:
        lib/UKIRT/JunkTrack.pm:our $TIME_TO_PREPARE = new DateTime::Duration(seconds => 10);
        lib/UKIRT/JunkTrack.pm:our $TIME_TO_START = new DateTime::Duration(seconds => 1);

    Directory:
        lib/UKIRT/JunkTrack.pm:our $MSB_DIR = '/jac_sw/itsroot/nasaFiles/edited';

    Translator:
        lib/UKIRT/JunkTrack/Translate.pm:our $TRANSLATOR = '/jac_sw/omp/QT/bin/UkirtTranslator.csh';
