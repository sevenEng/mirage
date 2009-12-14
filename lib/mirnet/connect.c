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

/* $Id: connect.c,v 1.12 2005/03/24 17:20:53 doligez Exp $ */

#include <fail.h>
#include <mlvalues.h>
#include <signals.h>
#include "unixsupport.h"

#include "socketaddr.h"

CAMLprim value unix_connect(value socket, value address)
{
  int retcode;
  union sock_addr_union addr;
  socklen_param_type addr_len;

  get_sockaddr(address, &addr, &addr_len);
  enter_blocking_section();
  retcode = connect(Int_val(socket), &addr.s_gen, addr_len);
  leave_blocking_section();
  if (retcode == -1) uerror("connect", Nothing);
  return Val_unit;
}
