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

if ( $#ARGV != 1 ) {
	print "Usage: savedoc.pl <original file> <target file>\n";
	exit(-1);
}
$fname1 = $ARGV[0];
$fname2 = $ARGV[1];
use Cwd;
my $dir = getcwd;
$cu = $pu->createInitialComponentContext("file://" . $dir . "/perluno");
$sm = $cu->getServiceManager();

$resolver = $sm->createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", $cu);

$smgr = $resolver->resolve("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager");

$rc = $smgr->getPropertyValue("DefaultContext");

$dt = $smgr->createInstanceWithContext("com.sun.star.frame.Desktop", $rc);

$pv = $pu->createIdlStruct("com.sun.star.beans.PropertyValue");

$pv->Name("Hidden");
$pv->Value(1);

@args = ( $pv );

$sdoc = $dt->loadComponentFromURL("file://" . $dir . "/" . $fname1, "_blank", 0, \@args);

$pv1 = $pu->createIdlStruct("com.sun.star.beans.PropertyValue");
$pv1->Name("Overwrite");
$pv1->Value(1);

$pv2 = $pu->createIdlStruct("com.sun.star.beans.PropertyValue");
$pv2->Name("FilterName");
$pv2->Value("swriter: StarOffice XML (Writer)");

@args2 = ( $pv1, $pv2 );

$sdoc->storeAsURL("file://" . $dir . "/" . $fname2, \@args2 );

return(0);
