#*************************************************************************
#
#   $RCSfile$
#
#   $Revision$
#
#   last change: $Author$ $Date$
#
#   The Contents of this file are made available subject to the terms of
#   either of the following licenses
#
#          - GNU Lesser General Public License Version 2.1
#          - Sun Industry Standards Source License Version 1.1
#
#   Sun Microsystems Inc., October, 2000
#
#   GNU Lesser General Public License Version 2.1
#   =============================================
#   Copyright 2000 by Sun Microsystems, Inc.
#   901 San Antonio Road, Palo Alto, CA 94303, USA
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License version 2.1, as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston,
#   MA  02111-1307  USA
#
#
#   Sun Industry Standards Source License Version 1.1
#   =================================================
#   The contents of this file are subject to the Sun Industry Standards
#   Source License Version 1.1 (the "License"); You may not use this file
#   except in compliance with the License. You may obtain a copy of the
#   License at http://www.openoffice.org/license.html.
#
#   Software provided under this License is provided on an "AS IS" basis,
#   WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#   WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#   MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#   See the License for the specific provisions governing your rights and
#   obligations concerning the Software.
#
#   The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#   Copyright: 2000 by Sun Microsystems, Inc.
#
#   All Rights Reserved.
#
#   Contributor(s): _______________________________________
#
#
#
#*************************************************************************

PRJ=.

PRJNAME=perluno
TARGET=perluno

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------

TARFILE_NAME=perluno-0.01
TARFILE_ROOTDIR=perluno

.IF "$(GUI)"=="UNX"
.IF "$(COMNAME)"=="sunpro5"
.IF "$(BUILD_TOOLS)$/cc"=="$(shell +-which cc)"
CC:=$(COMPATH)$/bin$/cc
CXX:=$(COMPATH)$/bin$/CC
.ENDIF          # "$(BUILD_TOOLS)$/cc"=="$(shell +-which cc)"
.ENDIF          # "$(COMNAME)"=="sunpro5"

CONFIGURE_DIR=source/XS

CONFIGURE_ACTION=perl Makefile.PL

BUILD_DIR=$(CONFIGURE_DIR)
BUILD_ACTION=$(GNUMAKE)
OUT2LIB= \
	$(BUILD_DIR)$/blib$/arch$/auto$/Perluno$/Perluno.so
.ENDIF

# --- Targets ------------------------------------------------------

all: \
	$(MISC)$/remove_build.flag \
	ALLTAR

maketar::
	rm -f download/perluno-0.01.tar.gz
	(cd ..;tar cvf perluno/download/perluno-0.01.tar -T perluno/flist.lst;cd perluno)
	gzip download/perluno-0.01.tar

.INCLUDE : set_ext.mk
.INCLUDE :	target.mk
.INCLUDE :	tg_ext.mk

.IF "$(BINARY_PATCH_FILE_NAME)"!=""

$(PACKAGE_DIR)$/so_add_binary :  $(PACKAGE_DIR)$/$(ADD_FILES_FLAG_FILE)
	cd $(PACKAGE_DIR) && gunzip -c $(BACK_PATH)$(BINARY_PATCH_FILE_NAME) | tar $(TAR_EXCLUDE_SWITCH) -xvf -
	+$(TOUCH) $(PACKAGE_DIR)$/so_add_binary

$(PACKAGE_DIR)$/$(CONFIGURE_FLAG_FILE) : $(PACKAGE_DIR)$/so_add_binary

.ENDIF

# Since you never know what will be in a patch (for example, it may already
# patch at configure level) or in the case of a binary patch, we remove the
# entire package directory if a patch is newer.
# Changes in this makefile could also make a complete build necessary if
# configure is affected.
$(MISC)$/remove_build.flag : $(BINARY_PATCH_FILE_NAME) $(PATCH_FILE_NAME) makefile.mk
	$(REMOVE_PACKAGE_COMMAND)
	+$(TOUCH) $(MISC)$/remove_build.flag

