BEGIN { $| = 1; print "1..2\n"; }
END { print "not ok 1\n" unless $loaded; }
use OpenOffice::UNO;

my $pu = new OpenOffice::UNO();

use Cwd;
my $dir = getcwd;
my $cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");

my $sm = $cu->getServiceManager();

eval {
    $sm->testMethod();
};
if( my $e = $@ ) {
    print "ok 1\n";
}

$loaded = 1;

print "ok 2\n";
