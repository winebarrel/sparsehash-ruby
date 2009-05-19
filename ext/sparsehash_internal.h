#ifndef __SPARSEHASH_INTERNAL_H__
#define __SPARSEHASH_INTERNAL_H__

#include "ruby.h"

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif
#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#ifdef _WIN32
#define __F(f) (reinterpret_cast<VALUE (__cdecl *)(...)>(f))
#else
#define __F(f) (reinterpret_cast<VALUE (*)(...)>(f))
#endif

extern "C" {
#ifdef _WIN32
__declspec(dllexport)
#endif
void Init_sparsehash();
}

#endif // __SPARSEHASH_INTERNAL_H__
