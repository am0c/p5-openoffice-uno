#!/usr/local/bin/perl
#*************************************************************************
#*
#*  $RCSfile$
#*
#*  $Revision$
#*
#*  last change: $Author$ $Date$
#*
#*  The Contents of this file are made available subject to the terms of
#*  the BSD license.
#*  
#*  Copyright (c) 2003 by Sun Microsystems, Inc.
#*  All rights reserved.
#*
#*  Redistribution and use in source and binary forms, with or without
#*  modification, are permitted provided that the following conditions
#*  are met:
#*  1. Redistributions of source code must retain the above copyright
#*     notice, this list of conditions and the following disclaimer.
#*  2. Redistributions in binary form must reproduce the above copyright
#*     notice, this list of conditions and the following disclaimer in the
#*     documentation and/or other materials provided with the distribution.
#*  3. Neither the name of Sun Microsystems, Inc. nor the names of its
#*     contributors may be used to endorse or promote products derived
#*     from this software without specific prior written permission.
#*
#*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#*  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
#*  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
#*  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
#*  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#*     
#*************************************************************************/
# Add module path for testing
push(@INC, $ENV{'SOLARVERSION'} . "/" . $ENV{'INPATH'} . "/lib/perl");

require "Perluno.pm";

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

$table = $sdoc->createInstance("com.sun.star.text.TextTable");

$table->initialize(4, 4);
$oText->insertTextContent($oCursor, $table, 0);

$rows = $table->getRows();

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

#values = ( (22.5,21.5,121.5),
#           (5615.3,615.3,-615.3),
#           (-2315.7,315.7,415.7) )

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

$pv1 = $pu->createIdlStruct("com.sun.star.beans.PropertyValue");
$pv1->Name("Overwrite");
$pv1->Value(new Perluno::Boolean(TRUE));

$pv2 = $pu->createIdlStruct("com.sun.star.beans.PropertyValue");
$pv2->Name("FilterName");
$pv2->Value("swriter: StarOffice XML (Writer)");

@args2 = ( $pv1, $pv2 );

# save file into newfile.sxw
$sdoc->storeAsURL("file://" . $dir . "/newfile.sxw", \@args2 );

$sdoc->dispose();

exit(0);

sub insertTextIntoCell {
    local($table) = $_[0];
    local($cellName) = $_[1];
    local($text) = $_[2];
    local($color) = $_[3];

    $tableText = $table->getCellByName( $cellName );
    $cursor = $tableText->createTextCursor();
    $cursor->setPropertyValue( "CharColor", $color );
    $tableText->setString( $text );
}
