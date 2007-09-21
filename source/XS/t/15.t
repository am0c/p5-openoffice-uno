#!/usr/bin/perl -w

use strict;
use warnings;
use lib qw(t/lib);
use Test::More tests => 1;

use UnoTest;
use OpenOffice::UNO;

my $pu = new OpenOffice::UNO();

my $cu = get_cu($pu);
my $sm = $cu->getServiceManager();

my $resolver = $sm->createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", $cu);

my $smgr = $resolver->resolve("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager");

my $rc = $smgr->getPropertyValue("DefaultContext");

my $dt = $smgr->createInstanceWithContext("com.sun.star.frame.Desktop", $rc);

my @args = ();

my $sdoc = $dt->loadComponentFromURL("private:factory/swriter", "_blank", 0, \@args);

my $oText = $sdoc->getText();

my $oCursor = $oText->createTextCursor();

$oCursor->setPropertyValue("CharColor", new OpenOffice::UNO::Int32(255));
$oCursor->setPropertyValue("CharShadowed", new OpenOffice::UNO::Boolean(1));

$oText->insertString($oCursor, " This is a colored Text - blue with shadow\n", new OpenOffice::UNO::Boolean(0));

$sdoc->dispose();

ok( 1, 'Got there' );
