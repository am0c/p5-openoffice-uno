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

#include "Perluno.h"

// Perluno Runtime Instance
static PerlRT PerlunoInstance;

Perluno::Perluno() {
}

Perluno::~Perluno() {
    PerlunoInstance.prtInitialized = FALSE;
}

void
Perluno::createServices() {
    PerlunoInstance.ssf = Perluno_XSingleServiceFactory(
	PerlunoInstance.localCtx->getServiceManager()->createInstanceWithContext(
	    PERLUNO_INVOCATION_OBJECT, PerlunoInstance.localCtx ), ::com::sun::star::uno::UNO_QUERY );

    if( ! PerlunoInstance.ssf.is() )
	throw ::com::sun::star::uno::RuntimeException(
	    ::rtl::OUString( RTL_CONSTASCII_USTRINGPARAM( "Perluno: couldn't instantiate Single Service Manager" )),
		Perluno_XInterface () );

    PerlunoInstance.typecvt = Perluno_XTypeConverter(
	PerlunoInstance.localCtx->getServiceManager()->createInstanceWithContext(
	    PERLUNO_TYPECONVERTER_OBJECT, PerlunoInstance.localCtx ), ::com::sun::star::uno::UNO_QUERY );

    if( ! PerlunoInstance.typecvt.is() )
	throw ::com::sun::star::uno::RuntimeException(
	    ::rtl::OUString( RTL_CONSTASCII_USTRINGPARAM( "Perluno: couldn't instantiate typeconverter service" )),
		Perluno_XInterface () );
}

Perluno_Interface *
Perluno::createInitialComponentContext(char *iniFile) {
    PerlunoInstance.localCtx = cppu::defaultBootstrap_InitialComponentContext(
	::rtl::OUString::createFromAscii(iniFile) );
    PerlunoInstance.prtInitialized = TRUE;
    createServices();

    Perluno_XAny tany;
    tany <<= PerlunoInstance.localCtx;

    ctx = new Perluno_Interface(tany);
    return ctx;
}

Perluno_Interface *
Perluno::createInitialComponentContext() {
    PerlunoInstance.localCtx = cppu::defaultBootstrap_InitialComponentContext();
    PerlunoInstance.prtInitialized = TRUE;
    createServices();

    Perluno_XAny tany;
    tany <<= PerlunoInstance.localCtx;

    ctx = new Perluno_Interface(tany);
    return ctx;
}

Perluno_Interface::Perluno_Interface() {
}

Perluno_Interface::Perluno_Interface(Perluno_XAny thisif) {
    Perluno_SAny args(1);
    Perluno_XInterface tif;

    // Check if ref is valid
    Perluno_XInterface cif;
    thisif >>= cif;
    if ( ! cif.is() ) {
	fprintf(stderr, "Perluno: invalid interface ref\n");
        return;
    }

    args[0] <<= thisif;
    tif = PerlunoInstance.ssf->createInstanceWithArguments(args);
    if ( ! tif.is() ) {
	fprintf(stderr, "Perluno: Proxy creation failed\n");
        return;
    }

    xinvoke = Perluno_XInvocation2(tif, ::com::sun::star::uno::UNO_QUERY);

    if ( ! xinvoke.is() ) {
	fprintf(stderr, "Perluno: XInvocation2 failed to be created\n");
        return;
    }

    pany = thisif;
    setObjType(PERLUNO_OBJECT_INTERFACE_TYPE);
}

SV *
Perluno_Interface::invoke(char *method, Perluno_SAny args) {
    I32 i;
    ::rtl::OUString mstr = ::rtl::OUString::createFromAscii(method);
    if ( ! xinvoke.is() ) {
	fprintf(stderr, "Perluno: Invalid XInvocation2 ref\n");
	return (SV *)Nullsv;
    }

    if ( ! xinvoke->hasMethod(mstr) ) {
	fprintf(stderr, "Perluno: Method: \"%s\" is NOT defined\n", method);
	return (SV *)Nullsv;
    }

    Perluno_SAny oargs;
    Perluno_SShort oidx;
    Perluno_XAny ret_val;

    ret_val = xinvoke->invoke(mstr, args, oidx, oargs);

    SV *retval = Nullsv;
    if ( oargs.getLength() > 0 ) {
	AV *av;

	av = newAV();

	// Store return value
	SV *trv = AnyToSV(ret_val);
	av_store(av, 0, trv);

	// Convert output parameters
	av_extend(av, oargs.getLength()+1);
	for ( int i = 0; i < oargs.getLength(); i++ ) {
	    SV *tav = AnyToSV(PerlunoInstance.typecvt->convertTo(oargs[i], oargs[i].getValueType()));
	    av_store(av, i+1, tav);
	}
	retval = (SV *)av;
    } else {
	// Convert return value
	retval = AnyToSV(ret_val);
    }

    return retval;
}

Perluno_XAny
Perluno_Any::getAny() {
	return pany;
}

long
Perluno_Any::getObjType() {
    return ObjType;
}


void
Perluno_Any::setObjType(long otype) {
    ObjType = otype;
}

static void
PerlunoExit(pTHX_ void *pi) {
}

void
Bootstrap(pTHX) {
    dSP;

    PerlunoInstance.prtInitialized = 0;

    perl_atexit(PerlunoExit, (void *)&PerlunoInstance);
}

Perluno_SAny
AVToSAny(AV *parr) {
    Perluno_SAny aany;

    if ( av_len(parr) >= 0 ) {
	aany.realloc(av_len(parr) + 1);
	for ( int i = 0; i <= av_len(parr); i++ ) {
	    aany[i] = SVToAny(*av_fetch(parr, i, FALSE));
	}
    }
    return aany;
}

Perluno_XAny
SVToAny(SV *svp) {
    Perluno_XAny a;

    switch ( SvTYPE(svp) ) {
	case SVt_NULL:
	    break;

	case SVt_IV: {
	    long intval = (long) SvIVX(svp);
	    a <<= intval;
	    break;
	}

	case SVt_NV:
	    (long) SvNVX(svp);
	    break;

	case SVt_RV: {
	    if (SvROK(svp)) {
		switch ( SvTYPE(SvRV(svp)) ) {
		     case SVt_PVAV: {
			AV *parr = (AV *)SvRV(svp);
			Perluno_SAny aany = AVToSAny(parr);
			a <<= aany;

			break;
		    }

		    case SVt_RV: {
			long otype;
			IV tmp = SvIV((SV*)SvRV(svp));
			Perluno_Any *tptr = INT2PTR(Perluno_Any *,tmp);
			a <<= tptr->getAny();
			break;
		    }

		    case SVt_PVMG: {
			long otype;
			IV tmp = SvIV((SV*)SvRV(svp));
			Perluno_Any *tptr = INT2PTR(Perluno_Any *,tmp);
			a <<= tptr->getAny();
			break;
		    }

		    default:
			fprintf(stderr, "SVToAny: Unsupported reference type\n");
			break;
		}
	    }
	    break;
	}

	case SVt_PV: {
	    // Extract String
	    char *tstr = SvPVX(svp);
	    ::rtl::OUString ostr = ::rtl::OUString::createFromAscii(tstr);
	    a <<= ostr;
	    break;
	}

	case SVt_PVIV:
		break;

	case SVt_PVNV:
		break;

	case SVt_PVMG:
		break;

	case SVt_PVBM:
		break;

	case SVt_PVLV:
		break;

	case SVt_PVAV:
		break;

	case SVt_PVHV:
		break;

	case SVt_PVCV:
		break;

	case SVt_PVGV:
		break;

	case SVt_PVFM:
		break;

	case SVt_PVIO:
		break;

	default:
	    fprintf(stderr, "SVToAny: UNKNOWN Perl type\n");
	    break;
    }

    return a;
}

AV *
SAnyToAV(Perluno_SAny sa) {
    AV *av;

    av = newAV();
    av_extend(av, sa.getLength());
    for ( int i = 0; i < sa.getLength(); i++ ) {
	SV *tav = AnyToSV(PerlunoInstance.typecvt->convertTo(sa[i], sa[i].getValueType()));
	av_store(av, i, tav);
    }
    return av;
}

SV *
AnyToSV(Perluno_XAny a) {
    SV *svp;
    SV *ret;

    ret = Nullsv;

    switch (a.getValueTypeClass()) {
	case typelib_TypeClass_VOID: {
	    ret = Nullsv;
	    break;
	}

	case typelib_TypeClass_CHAR: {
	    sal_Unicode c = *(sal_Unicode*)a.getValue();
	    ret = SvRV(newSViv(c));
	    break;
	}

	case typelib_TypeClass_BOOLEAN: {
	    sal_Bool b;
	    a >>= b;
	    if (b) ret = SvRV(newSViv(1));
	    else ret = SvRV(newSViv(0));
	    break;
	}

	case typelib_TypeClass_BYTE:
	case typelib_TypeClass_SHORT:
	case typelib_TypeClass_UNSIGNED_SHORT: 
	case typelib_TypeClass_LONG: {
	    long l;
	    a >>= l;
	    ret = SvRV(newSViv(l));
	    break;
	}

	case typelib_TypeClass_UNSIGNED_LONG: { 
	    unsigned long l;
	    a >>= l;
	    ret = SvRV(newSViv(l));
	    break;
	} 

	case typelib_TypeClass_HYPER: {
	    sal_Int64 l;
	    a >>= l;
	    ret = SvRV(newSViv(l));
	    break;
	}

	case typelib_TypeClass_UNSIGNED_HYPER: {
	    sal_uInt64 l;
	    a >>= l;
	    ret = SvRV(newSViv(l));
	    break;
	}

	case typelib_TypeClass_FLOAT: {
	    float f;
	    a >>= f;
	    ret = SvRV(newSVnv(f));
	    break;
	}

	case typelib_TypeClass_DOUBLE: {
	    double d;
	    a >>= d;
	    ret = SvRV( newSVnv(d));
	    break;
	}

	case typelib_TypeClass_STRING: {
	    ::rtl::OUString tmp_ostr;
	    a >>= tmp_ostr;

	    ::rtl::OString o = ::rtl::OUStringToOString(tmp_ostr, RTL_TEXTENCODING_UTF8);

	    svp = sv_2mortal(newSVpv(o.getStr(), o.getLength()));
	    SvUTF8_on(svp);
	    break;
	}

	case typelib_TypeClass_TYPE: {
	    ::com::sun::star::uno::Type t;
	    a >>= t;
	    ::rtl::OString o = ::rtl::OUStringToOString( t.getTypeName(), RTL_TEXTENCODING_ASCII_US );
	    ret = SvRV(newSVpv(o.getStr(), (com::sun::star::uno::TypeClass)t.getTypeClass()));
	    break;
	}

	case typelib_TypeClass_ANY: {
	    fprintf(stderr, "Any2SV: ANY type not supported yet\n");
	    ret = Nullsv;
	    break;
	}

	case typelib_TypeClass_ENUM: {
	    fprintf(stderr, "Any2SV: ENUM type not supported yet\n");
	    ret = Nullsv;
	    break;
	}

	case typelib_TypeClass_EXCEPTION:
	case typelib_TypeClass_STRUCT: {
	    fprintf(stderr, "Any2SV: EXCEPTION or STRUCT type not supported yet\n");
	    ret = Nullsv;
	    break;
	}

	case typelib_TypeClass_SEQUENCE: {
	    Perluno_SAny sa;
	    PerlunoInstance.typecvt->convertTo(a, ::getCppuType(&sa)) >>= sa;
	    ret = (SV *)SAnyToAV(sa);
	    break;
	}

	case typelib_TypeClass_INTERFACE: {
	    Perluno_Interface *tret = new Perluno_Interface(a);
	    SV *mret = sv_newmortal();
	    ret = newRV_inc(mret);
	    sv_setref_pv(ret, "Perluno::Interface", (void *)tret);
	    break;
	}

	default: {
	    fprintf(stderr, "Any2SV: Error Unknown Any type\n");
	    ret = Nullsv;
	    break;
	}
    }
    return ret;
}

MODULE = Perluno     	PACKAGE = Perluno	PREFIX = Perluno_

PROTOTYPES: DISABLE

BOOT:
    Bootstrap(aTHX);

Perluno *
Perluno::new(...)
CODE:
{
    RETVAL = new Perluno();
}
OUTPUT:
    RETVAL

Perluno_Interface *
Perluno::createInitialComponentContext(...)
CODE:
{
    if ( items == 1 ) {
	RETVAL = THIS->createInitialComponentContext();
    } else if ( items == 2 ) {
	char *iniFile;
	STRLEN len;

	iniFile = SvPV(ST(1), len);
	RETVAL = THIS->createInitialComponentContext(iniFile);
    }
}
OUTPUT:
    RETVAL

MODULE = Perluno	PACKAGE = Perluno::Interface	PREFIX = Perluno_

Perluno_Interface *
Perluno_Interface::new(...)
CODE:
{
    Perluno_Interface *retval;
    
    retval = new Perluno_Interface();

    RETVAL = retval;
}
OUTPUT:
    RETVAL

SV *
Perluno_Interface::AUTOLOAD(...)
CODE:
{
    CV *method = get_cv("Perluno::Interface::AUTOLOAD", 0);

    I32 i;
    Perluno_SAny args;

    if ( items > 1 ) {
	args.realloc(items-1);
	for ( i = 1; i < items; i++ ) {
	    Perluno_XAny a = SVToAny(ST(i));
	    args[i-1] <<= a;
	}
    }

    RETVAL = THIS->invoke(SvPVX(method), args);
}
OUTPUT:
    RETVAL

void
Perluno_Interface::DESTROY(...)
CODE:
{
    delete(THIS);
}
