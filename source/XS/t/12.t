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

# create a blank calc document
my @args = ();
my $sdoc = $dt->loadComponentFromURL("private:factory/scalc", "_blank", 0, \@args);

# Close doc
$sdoc->dispose();

ok( 1, 'Got there' );
