/*
 * vim: ts=4 sw=4 et tw=0 wm=0
 *
 * libavoid - Fast, Incremental, Object-avoiding Line Router
 *
 * Copyright (C) 2004-2008  Monash University
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * See the file LICENSE.LGPL distributed with the library.
 *
 * Licensees holding a valid commercial license may use this file in
 * accordance with the commercial license agreement provided with the 
 * library.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *
 * Author(s):   Michael Wybrow <mjwybrow@users.sourceforge.net>
*/


#ifndef AVOID_DEBUG_H
#define AVOID_DEBUG_H


#ifdef LIBAVOID_DEBUG

  #ifdef _MSC_VER
    // Compiling with Microsoft Visual C++ compiler

    // Prevent inclusion of min and max macros.
    #define NOMINMAX

    #include <afx.h>

  #endif

#include <stdarg.h>
#include <iostream>

#endif

namespace Avoid {

#ifdef LIBAVOID_DEBUG

  #ifdef _MSC_VER
    // Compiling with Microsoft Visual C++ compiler

    #define db_printf  ATL::AtlTrace
    #define err_printf ATL::AtlTrace
  #else
    inline void db_printf(const char *fmt, ...)
    {
        va_list ap;
        va_start(ap, fmt);
        vfprintf(stdout, fmt, ap);
        va_end(ap);
    }
    inline void err_printf(const char *fmt, ...)
    {
        va_list ap;
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
    }
  #endif

#else

    inline void db_printf(const char *, ...)
    {
    }
    inline void err_printf(const char *, ...)
    {
    }

#endif

}


#endif


