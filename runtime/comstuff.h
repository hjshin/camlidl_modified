/***********************************************************************/
/*                                                                     */
/*                              CamlIDL                                */
/*                                                                     */
/*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         */
/*                                                                     */
/*  Copyright 1999 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License.         */
/*                                                                     */
/***********************************************************************/

/* $Id: comstuff.h,v 1.11 2001-06-09 14:48:20 xleroy Exp $ */

/* Load or emulate COM-related includes */

#ifdef _WIN32

#include <wtypes.h>
#include <winbase.h>

#else

/* Emulation for other OS */

interface IUnknown;

struct IUnknownVtbl {
  DECLARE_VTBL_PADDING
  HRESULT (*QueryInterface)(interface IUnknown * this,
                            IID * iid, void ** object);
  ULONG (*AddRef)(interface IUnknown * this);
  ULONG (*Release)(interface IUnknown * this);
};

interface IUnknown {
  struct IUnknownVtbl * lpVtbl;
};

#define IsEqualIID(a,b) (memcmp(a, b, sizeof(IID)) == 0)
#define InterlockedIncrement(p) (++(*(p)))
#define InterlockedDecrement(p) (--(*(p)))
extern IID IID_IUnknown;
#define S_TRUE S_OK
#define S_FALSE 1
#define E_NOINTERFACE 0x80004002
#define CLASS_E_NOAGGREGATION 0x80040110
#define CO_E_IIDSTRING 0x800401f4
#define FAILED(hr) ((hr) & 0x80000000)
#define HRESULT_CODE(hr) ((hr) & 0xFFFF)
#define SEVERITY_ERROR 1
#define SEVERITY_SUCCESS 0
#define FACILITY_NULL 0
#define FACILITY_ITF 4
#define MAKE_HRESULT(s,f,c) (((s) << 31) | ((f) << 16) | (c))

#endif

/* Internal functions and data */

#ifdef __cplusplus
extern "C"{
#endif 

#define GUID_val(v) (*((GUID *) Bp_val(v)))

/* Count of active component instances */

extern int camlidl_num_components;

/* Handle for module (for the DLL) */

#ifdef _WIN32
extern HMODULE camlidl_module_handle;
#endif

/* The list of all registered components */

struct camlidl_comp {
  value compdata;
  struct camlidl_comp * next;
};

extern struct camlidl_comp * camlidl_registered_components;

/* Structure of the "compdata" Caml record */

#define COMPDATA_CREATE 0
#define COMPDATA_CLSID 1
#define COMPDATA_FRIENDLY_NAME 2
#define COMPDATA_VER_IND_PROG_ID 3
#define COMPDATA_PROG_ID 4

/* Build a ISupportErrorInfo interface */
struct ISupportErrorInfo * camlidl_support_error_info(struct camlidl_intf * i);

/* Find the type library for the given IID */
struct IUnknown * camlidl_find_typeinfo(IID * iid);

#ifdef __cplusplus
}
#endif 

