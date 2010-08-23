/*  You may distribute under the terms of either the GNU General Public License
 *  or the Artistic License (the same terms as Perl itself)
 *
 *  (C) Paul Evans, 2010 -- leonerd@leonerd.org.uk
 *
 * Much of this code inspired by http://search.cpan.org/~jjore/UNIVERSAL-ref-0.12/
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int init_done = 0;

OP *(*real_pp_substr)(pTHX);

PP(pp_overload_substr) {
  dSP; dTARG;
  const int num_args = PL_op->op_private & 7; /* Horrible; stolen from pp.c:pp_subst */
  SV *self = *(SP - num_args + 1);
  GV *substr_method;
  SV *result;

  if(!sv_isobject(self))
    return (*real_pp_substr)(aTHX);

  substr_method = gv_fetchmeth(SvSTASH(SvRV(self)), "(substr", 7, 0);

  if(!substr_method)
    return (*real_pp_substr)(aTHX);

  /* TODO: We don't yet support LVALUE substr; i.e. substr(...) = $replacement
   */
  if(PL_op->op_flags & OPf_MOD || LVRET)
    Perl_croak(aTHX_ "overload::substr does not yet support LVALUE substr()");

  ENTER;
  SAVETMPS;

  /* This piece of evil trickery "pushes" all the args we already have on the
   * stack, by simply claiming the MARK to be at the bottom of this op's args
   */
  PUSHMARK(SP-num_args);
  PUTBACK;

  call_sv((SV*)GvCV(substr_method), G_SCALAR);

  SPAGAIN;
  result = POPs;

  SvREFCNT_inc(result);

  FREETMPS;
  LEAVE;

  XPUSHs(result);

  RETURN;
}

MODULE = overload::substr       PACKAGE = overload::substr

BOOT:
if(!init_done++) {
  real_pp_substr = PL_ppaddr[OP_SUBSTR];
  PL_ppaddr[OP_SUBSTR] = &Perl_pp_overload_substr;
}
