BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }
use OpenOffice::UNO;

$pu = new OpenOffice::UNO();

use Cwd;
my $dir = getcwd;
my $cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");

print STDERR "04\n";
my $sm = $cu->getServiceManager();

$loaded = 1;

print "ok 1\n";
