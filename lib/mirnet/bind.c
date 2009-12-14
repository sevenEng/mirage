/***********************************************************************/
/*                                                                     */
/*                           Objective Caml                            */
/*                                                                     */
/*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         */
/*                                                                     */
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License, with    */
/*  the special exception on linking described in file ../../LICENSE.  */
/*                                                                     */
/***********************************************************************/

/* $Id: bind.c,v 1.10 2005/03/24 17:20:53 doligez Exp $ */

#include <fail.h>
#include <mlvalues.h>
#include "unixsupport.h"

#include "socketaddr.h"
  
CAMLprim value unix_bind(value socket, value address)
{
  int ret;
  union sock_addr_union addr;
  socklen_param_type addr_len;

  get_sockaddr(address, &addr, &addr_len);
  ret = bind(Int_val(socket), &addr.s_gen, addr_len);
  if (ret == -1) uerror("bind", Nothing);
  return Val_unit;
}
