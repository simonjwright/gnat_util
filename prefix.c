/* Provide dummy implementations of functions called from osint.adb.

This file is part of the version of GNAT_Util created at Sourceforge
by Simon Wright and intended to allow the building of tools provided
by AdaCore in their GPL distributions.

GNAT_Util is free software; you can redistribute it and/or modify it
under the terms of the GNU Library General Public License as published
by the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

GNAT_Util is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with GCC; see the file COPYING3.  If not see
<http://www.gnu.org/licenses/>.  */

#include <string.h>

/* This is the comment from gcc/prefix.h:  */
/* Update PATH using KEY if PATH starts with PREFIX.  The returned
   string is always malloc-ed, and the caller is responsible for
   freeing it.  */
/* So we'd better allocate a copy in case the caller frees it!  */
char *update_path (const char *path, const char *key)
{
  return strdup(path);
}

void set_std_prefix (const char *prefix, int len)
{
}
