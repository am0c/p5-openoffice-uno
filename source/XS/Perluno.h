/*************************************************************************
 *
 *  $RCSfile$
 *
 *  $Revision$
 *
 *  last change: $Author$ $Date$
 *
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
 *   Contributor(s): Bustamam Harun
 *
 *
 ************************************************************************/

#ifndef _PERLUNO_H_

#define _PERLUNO_H_

#ifdef bool
#undef bool
#include <iostream.h>
#endif

#include <com/sun/star/connection/ConnectionSetupException.hpp>
#include <com/sun/star/lang/XMultiComponentFactory.hpp>
#include <com/sun/star/lang/XSingleServiceFactory.hpp>
#include <com/sun/star/lang/XMultiServiceFactory.hpp>
#include <com/sun/star/reflection/XIdlReflection.hpp>
#include <com/sun/star/beans/XMaterialHolder.hpp>
#include <com/sun/star/script/XTypeConverter.hpp>
#include <com/sun/star/uno/XComponentContext.hpp>
#include <com/sun/star/reflection/XIdlClass.hpp>
#include <com/sun/star/uno/RuntimeException.hpp>
#include <com/sun/star/beans/XIntrospection.hpp>
#include <com/sun/star/script/XInvocation2.hpp>
#include <com/sun/star/lang/XTypeProvider.hpp>
#include <com/sun/star/lang/XServiceInfo.hpp>
#include <com/sun/star/uno/XInterface.hpp>
#include <com/sun/star/uno/Reference.h>
#include <typelib/typedescription.hxx>
#include <cppuhelper/bootstrap.hxx>

#include <com/sun/star/uno/Any.hxx>

#include <rtl/strbuf.hxx>
#include <rtl/ustrbuf.hxx>

#ifdef __cplusplus
extern "C" {
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef __cplusplus
};
#endif

#define PERLUNO_INVOCATION_OBJECT ::rtl::OUString( RTL_CONSTASCII_USTRINGPARAM( "com.sun.star.script.Invocation" ))
#define PERLUNO_TYPECONVERTER_OBJECT ::rtl::OUString( RTL_CONSTASCII_USTRINGPARAM( "com.sun.star.script.Converter" ))
#define PERLUNO_COREREFLECTION_OBJECT ::rtl::OUString( RTL_CONSTASCII_USTRINGPARAM( "com.sun.star.reflection.CoreReflection" ))

#define PERLUNO_STRUCT_NAME_KEY "PerlunoStructName"

typedef ::com::sun::star::uno::Reference< ::com::sun::star::uno::XComponentContext > Perluno_XComponentContext;	
typedef ::com::sun::star::uno::Reference< ::com::sun::star::lang::XMultiComponentFactory > Perluno_XMultiComponentFactory;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::lang::XMultiServiceFactory > Perluno_XMultiServiceFactory;
//typedef ::com::sun::star::lang::XMultiComponentFactory Perluno_XMultiComponentFactory;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::uno::XInterface > Perluno_XInterface;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::lang::XSingleServiceFactory > Perluno_XSingleServiceFactory;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::script::XTypeConverter > Perluno_XTypeConverter;
typedef ::com::sun::star::uno::Any Perluno_XAny;
typedef ::com::sun::star::uno::Sequence< ::com::sun::star::uno::Any > Perluno_SAny;
typedef ::com::sun::star::uno::Sequence< short > Perluno_SShort;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::lang::XServiceInfo > Perluno_XServiceInfo;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::lang::XTypeProvider > Perluno_XTypeProvider;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::script::XInvocation2 > Perluno_XInvocation2;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::beans::XMaterialHolder > Perluno_XMaterialHolder;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::reflection::XIdlClass > Perluno_XIdlClass;
typedef ::com::sun::star::uno::Reference< ::com::sun::star::reflection::XIdlReflection > Perluno_XIdlReflection;


typedef struct _PerlRT {
	bool prtInitialized;
	Perluno_XComponentContext localCtx;
	Perluno_XSingleServiceFactory ssf;
	Perluno_XTypeConverter typecvt;
	Perluno_XIdlReflection reflection;
} PerlRT;

class Perluno_Any {
public:
	Perluno_Any() {};
	~Perluno_Any() {};
	Perluno_XAny getAny();

	Perluno_XInvocation2 xinvoke;

protected:
	Perluno_XAny pany;
};

class Perluno_Struct : Perluno_Any {
public:
	Perluno_Struct();
	Perluno_Struct(char *stype);
	Perluno_Struct(Perluno_XAny tinterface);
	~Perluno_Struct();

	void set(char *mname, SV *value);
	SV *get(char *mname);

private:
	char *TypeString;
};

class Perluno_Interface : Perluno_Any {
public:
	Perluno_Interface();
	Perluno_Interface(Perluno_XAny targetInterface);
	~Perluno_Interface() {};

	SV * invoke(char *method, Perluno_SAny args);
};

class Perluno_Util {
public:
	Perluno_Util() {};
	~Perluno_Util() {};
};

class Perluno {
public:
    Perluno();
    ~Perluno();

    Perluno_Interface *createInitialComponentContext();
    Perluno_Interface *createInitialComponentContext(char *iniFile);
    Perluno_Struct *createIdlStruct(char *name);

private:
    void createServices();

    Perluno_Interface *ctx;
};

// Function Prototype
Perluno_SAny AVToSAny(AV *av);
Perluno_XAny HVToStruct(HV *hv);
Perluno_XAny SVToAny(SV *svp);
SV *AnyToSV(Perluno_XAny a);
AV *SAnyToAV(Perluno_SAny sa);

#endif
