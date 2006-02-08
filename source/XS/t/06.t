BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }
use Perluno;

my $pu = new Perluno();

use Cwd;
my $dir = getcwd;
my $cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");

my $sm = $cu->getServiceManager();

$sm->createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", $cu);

$loaded = 1;

print "ok 1\n";
