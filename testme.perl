#!/usr/bin/perl -wd

use lib qw(./blib/lib ./blib/arch);
use PDL;
use PDL::Ngrams;

BEGIN{ $, = ' '; our $eps=1e-6; }

##---------------------------------------------------------------------
## test: rlevec, rldvec

sub rlevec_data {
  our $p2d  = pdl([[1,2],[3,4],[1,3],[1,2],[3,3]]) if (!defined($p));
  our $p2ds = $p2d->qsortvec;  ##-- broken in default PDL-2.4.3 (and debian <= 2.4.3-3)
  #our $p2duv = $p2d->uniqvec; ##-- ought to work too

  our $p  = $p2d;
  our $ps = $p2ds;
}

sub test_rlevec {
  rlevec_data;
  our ($puf,$pur) = rlevec($ps);
  our $ps2        = rldvec($puf,$pur);
  print all($ps==$ps2) ? "ok" : "not ok", "\n";
}
#test_rlevec;

##---------------------------------------------------------------------
## test: rlevec, rldvec: native

sub rlevec_data_nd {
  our $pnd1 = (1  *(sequence(long, 2,3  )+1))->slice(",,*3");
  our $pnd2 = (10 *(sequence(long, 2,3  )+1))->slice(",,*2");
  our $pnd3 = (100*(sequence(long, 2,3,2)+1));
  our $pnd  = $pnd1->mv(-1,0)->append($pnd2->mv(-1,0))->append($pnd3->mv(-1,0))->mv(0,-1);
  our $pnds = $pnd; ##-- pre-sorted
  our $p    = $pnd; ##-- alias
  our $ps   = $pnd; ##-- alias
}

##-- good general n-dimensional method, but keep 'rlevec' as 2d-optimized version
sub test_rlevec_native {
  #rlevec_data();
  rlevec_data_nd();

  our @pdims = $ps->dims;
  our $pdimN = $#pdims;   ##-- "-1" should work, too
  our $N     = $ps->dim($pdimN);

  our $ps_prev    = $ps->mv($pdimN,0)->rotate(1)->mv(0,$pdimN);
  our $ps_ismatch = zeroes(byte,@pdims);
  $ps->eq($ps_prev, $ps_ismatch, 0);
  $ps_ismatch->dice_axis($pdimN,0) .= 0; ##-- first element is NEVER a match
  #our $ps_nomatch = !$ps_ismatch;       ##-- not needed

  ##-- get number of non-redundant values
  #our $ps_ismatch_andover = $ps_ismatch->andover;
  #our $ps_nomatch_orover  = !$ps_ismatch_andover;  ## == $ps_nomatch->orover();
  ##our $nvals = $ps_nomatch_orover->sumover->max;
  #our $valni = $ps_nomatch_orover->cumusumover->where($ps_nomatch_orover);
  #
  ##-- STILL BUGGY
  #our $ps_ismatch_andover = $ps_ismatch->clump($pdimN)->andover;
  #our $ps_nomatch_orover  = !$ps_ismatch_andover;
  #our $vals   = $ps->dice_axis($pdimN,$valni);
  #our $counts = $ps_ismatch_andover->index($valni)+1;
  ##
  ##--
  our $ps_ismatch_andover =  $ps_ismatch->clump($pdimN)->andover->convert(long);
  our $ps_nomatch_orover  = !$ps_ismatch_andover;
  our $ismatch_offsets    = $ps_ismatch_andover->cumusumover->where($ps_nomatch_orover);
  our $nomatch_offsets    = $ps_nomatch_orover->cumusumover->where($ps_nomatch_orover);
  our $val_ni             = $ismatch_offsets + $nomatch_offsets -1;

  our $val_seq             = $ps_nomatch_orover->cumusumover; ##-- dummy, for low-level rle() call
  our ($val_cts,$val_seqi) = $val_seq->rle();

  ##-- try again: construct input for low-level call to rle()
  
}
test_rlevec_native();



##---------------------------------------------------------------------
## DUMMY
##---------------------------------------------------------------------
foreach $i (0..3) {
  print "--dummy($i)--\n";
}

