/**
 * \brief Remove overlaps function
 *
 * Authors:
 *   Tim Dwyer <tgdwyer@gmail.com>
 *
 * Copyright (C) 2005 Authors
 *
 * Released under GNU LGPL.  Read the file 'COPYING' for more information.
 */
#include "variable.h"
std::ostream& operator <<(std::ostream &os, const Variable &v) {
	os << "(" << v.id << "=" << v.position() << ")";
	return os;
}

