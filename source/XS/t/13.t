BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use OpenOffice::UNO;

$pu = new OpenOffice::UNO();

use Cwd;
my $dir = getcwd;
my $cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");
my $sm = $cu->getServiceManager();

my $resolver = $sm->createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", $cu);

my $smgr = $resolver->resolve("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager");

my $rc = $smgr->getPropertyValue("DefaultContext");

my $dt = $smgr->createInstanceWithContext("com.sun.star.frame.Desktop", $rc);

my $pv = $pu->createIdlStruct("com.sun.star.beans.PropertyValue");

$pv->Name("Hidden");
$pv->Value(1);

@args = ( $pv );

# open an existing word doc, with PropertyValues
my $sdoc = $dt->loadComponentFromURL("file://" . $dir . "/test1.sxw", "_blank", 0, \@args);

# Close doc
$sdoc->dispose();

$loaded = 1;

print "ok 1\n";

