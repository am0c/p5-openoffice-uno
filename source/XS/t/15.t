BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Perluno;

$pu = new Perluno();

use Cwd;
my $dir = getcwd;
$cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");
$sm = $cu->getServiceManager();

$resolver = $sm->createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", $cu);

$smgr = $resolver->resolve("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager");

$rc = $smgr->getPropertyValue("DefaultContext");

$dt = $smgr->createInstanceWithContext("com.sun.star.frame.Desktop", $rc);

@args = ();

$sdoc = $dt->loadComponentFromURL("private:factory/swriter", "_blank", 0, \@args);

$oText = $sdoc->getText();

$oCursor = $oText->createTextCursor();

$oCursor->setPropertyValue("CharColor", 255);
$oCursor->setPropertyValue("CharShadowed", new Perluno::Boolean(TRUE));

$oText->insertString($oCursor, " This is a colored Text - blue with shadow\n", new Perluno::Boolean(FALSE));

$sdoc->dispose();

$loaded = 1;

print "ok 1\n";
