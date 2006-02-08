BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Perluno;

my $pu = new Perluno();

use Cwd;
my $dir = getcwd;
my $cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");
my $sm = $cu->getServiceManager();

my $resolver = $sm->createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", $cu);

my $smgr = $resolver->resolve("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager");

my $rc = $smgr->getPropertyValue("DefaultContext");

my $dt = $smgr->createInstanceWithContext("com.sun.star.frame.Desktop", $rc);

@args = ();

my $sdoc = $dt->loadComponentFromURL("private:factory/swriter", "_blank", 0, \@args);

my $oText = $sdoc->getText();

my $oCursor = $oText->createTextCursor();

$oCursor->setPropertyValue("CharColor", 255);
$oCursor->setPropertyValue("CharShadowed", new Perluno::Boolean(TRUE));

$oText->insertString($oCursor, " This is a colored Text - blue with shadow\n", new Perluno::Boolean(FALSE));

$sdoc->dispose();

$loaded = 1;

print "ok 1\n";
