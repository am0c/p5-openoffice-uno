BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use OpenOffice::UNO;

my $pu = new OpenOffice::UNO();

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

my $table = $sdoc->createInstance("com.sun.star.text.TextTable");

$table->initialize(4, 4);
$oText->insertTextContent($oCursor, $table, 0);

my $rows = $table->getRows();

$table->setPropertyValue("BackTransparent", new Perluno::Boolean(FALSE));
$table->setPropertyValue("BackColor", 13421823 );

$row = $rows->getByIndex(0);
$row->setPropertyValue("BackTransparent", new Perluno::Boolean(0));
$row->setPropertyValue("BackColor", 6710932 );

$textColor = 16777215;

&insertTextIntoCell($table, "A1", "FirstColumn", $textColor);
&insertTextIntoCell($table, "B1", "SecondColumn", $textColor);
&insertTextIntoCell($table, "C1", "ThirdColumn", $textColor);
&insertTextIntoCell($table, "D1", "SUM", $textColor);

$table->getCellByName("A2")->setValue(22.5);
$table->getCellByName("B2")->setValue(5615.3);
$table->getCellByName("C2")->setValue(-2315.7);
$table->getCellByName("D2")->setFormula("sum <A2:C2>");

$table->getCellByName("A3")->setValue(21.5);
$table->getCellByName("B3")->setValue(615.3);
$table->getCellByName("C3")->setValue(-315.7);
$table->getCellByName("D3")->setFormula("sum <A3:C3>");

$table->getCellByName("A4")->setValue(121.5);
$table->getCellByName("B4")->setValue(-615.3);
$table->getCellByName("C4")->setValue(415.7);
$table->getCellByName("D4")->setFormula("sum <A4:C4>");

$sdoc->dispose();

$loaded = 1;

print "ok 1\n";

sub insertTextIntoCell {
    local($tabl) = $_[0];
    local($cellName) = $_[1];
    local($text) = $_[2];
    local($color) = $_[3];

    $tableText = $tabl->getCellByName( $cellName );
    $cursor = $tableText->createTextCursor();
    $cursor->setPropertyValue( "CharColor", $color );
    $tableText->setString( $text );
}
