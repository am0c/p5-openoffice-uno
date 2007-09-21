package UnoTest;

use strict;
use warnings;
use Exporter; *import = \&Exporter::import;

our @EXPORT = qw(get_file get_cu);

use OpenOffice::UNO;
use Cwd;

sub get_cu {
    my ($pu) = @_;

    # can't make initialization with path work on Win32
    if ($^O eq 'MSWin32') {
        return $pu->createInitialComponentContext();
    } else {
        return $pu->createInitialComponentContext(get_file('perluno'));
    }
}

sub get_file {
    my ($file) = @_;
    my ($dir) = getcwd();

    if ($^O eq 'MSWin32') {
        # getcwd returns forward slashes, which is OK in this case
        return 'file:///' . $dir . '/' . $file;
    } else {
        return 'file://'  . $dir . '/' . $file;
    }
}

1;
