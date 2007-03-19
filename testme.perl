#!/usr/bin/perl -wd

use lib qw(./blib/lib ./blib/arch);
use PDL;
use PDL::Ngrams;

BEGIN{ $, = ' '; our $eps=1e-6; }

##---------------------------------------------------------------------
## test: rlevec, rldvec

sub rlevec_data {
  our $p  = pdl([[1,2],[3,4],[1,3],[1,2],[3,3]]);
  our $ps = $p->qsortvec;
  #our $puv = $p->uniqvec; ##-- ought to work too

  our ($puf,$pur) = rlevec($ps);
  our $ps2        = rldvec($puf,$pur);

  print all($ps==$ps2) ? "ok" : "not ok", "\n";
}
rlevec_data;



##---------------------------------------------------------------------
## DUMMY
##---------------------------------------------------------------------
foreach $i (0..3) {
  print "--dummy($i)--\n";
}

