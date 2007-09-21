package OpenOffice::UNO;

=head1 NAME

OpenOffice::UNO - interface to OpenOffice's UNO runtime

=head1 SYNOPSIS

  # Launch OpenOffice.org as a server
  $ ooffice \
      "-accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager"

  use OpenOffice::UNO;

  # connect to the OpenOffice.org server
  $uno = OpenOffice::UNO->new;
  $cxt = $uno->createInitialComponentContext;
  $sm  = $cxt->getServiceManager;
  $resolver = $sm->createInstanceWithContext
                  ("com.sun.star.bridge.UnoUrlResolver", $cxt);
  $rsm = $resolver->resolve
      ("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager");

  # get an instance of the Desktop service
  $rc = $rsm->getPropertyValue("DefaultContext");
  $desktop = $rsm->createInstanceWithContext("com.sun.star.frame.Desktop", $rc);

  # create a name/value pair to be used in opening the document
  $pv = $uno->createIdlStruct("com.sun.star.beans.PropertyValue");
  $pv->Name("Hidden");
  $pv->Value(OpenOffice::UNO::Boolean->new(0));

  # open a document
  $sdoc = $desktop->loadComponentFromURL("file:///home/jrandom/test1.sxw",
                                         "_blank", 0, [$pv]);

  # close the document
  $sdoc->dispose();

=head1 DESCRIPTION

This is a straight bridge to the OpenOffice.org API, so the definitve
reference is in the OpenOffice.org SDK.

The homepage for OpenOffice::UNO is http://perluno.sourceforge.net/

=cut

require Exporter; *import = \&Exporter::import;
require DynaLoader;

@ISA = qw(DynaLoader);
$VERSION = '0.04';
@EXPORT = qw( createComponentContext );

bootstrap OpenOffice::UNO;

package OpenOffice::UNO::Exception;

@ISA = qw(OpenOffice::UNO::Struct);

# warning about inherited AUTOLOAD for non-method 'Message'
*AUTOLOAD = \&OpenOffice::UNO::Struct::AUTOLOAD;

use overload
    '""'     => \&Message,
    ;

=head1 AUTHOR

Author: Bustamam Harun <bustamam@gmail.com>.

Maintainer: Mattia Barbon <mbarbon@cpan.org>

=head1 LICENSE

 *  The Contents of this file are made available subject to the terms of
 *  either of the following licenses
 *
 *         - GNU Lesser General Public License Version 2.1
 *         - Sun Industry Standards Source License Version 1.1
 *
 *  Sun Microsystems Inc., October, 2000
 *
 *  GNU Lesser General Public License Version 2.1
 *  =============================================
 *  Copyright 2000 by Sun Microsystems, Inc.
 *  901 San Antonio Road, Palo Alto, CA 94303, USA
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License version 2.1, as published by the Free Software Foundation.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 *  MA  02111-1307  USA
 *
 *
 *  Sun Industry Standards Source License Version 1.1
 *  =================================================
 *  The contents of this file are subject to the Sun Industry Standards
 *  Source License Version 1.1 (the "License"); You may not use this file
 *  except in compliance with the License. You may obtain a copy of the
 *  License at http://www.openoffice.org/license.html.
 *
 *  Software provided under this License is provided on an "AS IS" basis,
 *  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
 *  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
 *  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
 *  See the License for the specific provisions governing your rights and
 *  obligations concerning the Software.
 *
 *  The Initial Developer of the Original Code is: Ralph Thomas
 *
 *   Copyright: 2000 by Sun Microsystems, Inc.
 *
 *   All Rights Reserved.
 *
 *   Contributor(s): Bustamam Harun, Mattia Barbon

=cut

1;
