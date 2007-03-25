#!/usr/bin/perl -wd

use lib qw(./blib/lib ./blib/arch);
use PDL;
use PDL::Ngrams;

BEGIN{ $, = ' '; our $eps=1e-6; }

##---------------------------------------------------------------------
## utils: as for common.plt

sub isok {
  my ($lab,$test) = @_;
  print "$lab: ", ($test ? "ok" : "NOT ok"), "\n";
}

##---------------------------------------------------------------------
## test: rlevec, rldvec

sub rlevec_data {
  our $p2d  = pdl([[1,2],[3,4],[1,3],[1,2],[3,3]]) if (!defined($p));
  #our $p2ds = $p2d->qsortvec;  ##-- broken in default PDL-2.4.3 (and debian <= 2.4.3-3)
  #our $p2duv = $p2d->uniqvec; ##-- also broken
  ##--
  our $p2ds = _ng_qsortvec($p2d); ##-- workaround

  our $p  = $p2d;
  our $ps = $p2ds;
}
#rlevec_data();

sub test_rlevec {
  rlevec_data;
  our ($puf,$pur) = rlevec($ps);
  our $ps2        = rldvec($puf,$pur);
  print "test_rlevec: ", all($ps==$ps2) ? "ok" : "not ok", "\n";
}
#test_rlevec;

##---------------------------------------------------------------------
## test: rlend, rldnd: perl wrappers for clump() + rlevec(), rldvec()

sub rlevec_data_nd {
  our $pnd1 = (1  *(sequence(long, 2,3  )+1))->slice(",,*3");
  our $pnd2 = (10 *(sequence(long, 2,3  )+1))->slice(",,*2");
  our $pnd3 = (100*(sequence(long, 2,3,2)+1));
  our $pnd  = $pnd1->mv(-1,0)->append($pnd2->mv(-1,0))->append($pnd3->mv(-1,0))->mv(0,-1);
  our $pnds = $pnd; ##-- pre-sorted
  our $p    = $pnd; ##-- alias
  our $ps   = $pnd; ##-- alias
}

sub test_rle_nd {
  #rlevec_data;      ##-- base case   : ND methods should handle 2d data correctly: ok
  rlevec_data_nd();  ##-- general case: ND data

  our ($puf,$pur) = rleND($ps);
  our $ps2        = rldND($puf,$pur);
  print "test_rlend: ", all($ps==$ps2) ? "ok" : "not ok", "\n";
}
#test_rle_nd();


##---------------------------------------------------------------------
## test: ng_delimit()

sub test_ng_data {
  our $toks  = pdl(long,[1, 1,2, 1,2,3, 1,2,3,4   ]);
  our $toks2d = $toks->slice("*1,")->append((10*$toks)->slice("*1,"))->xchg(0,1);
  our $beg   = pdl(long,[0, 1,   3,     6         ]);
  our $end   = pdl(long,[   1,   3,     6,     10 ]);

  our $bos1  = pdl(long,[-1]);
  our $eos1  = $bos1;

  our $bos2  = pdl(long,[-2,-1]);
  our $eos2  = pdl(long,[1000,2000]);
}

sub test_ng_delimit {
  test_ng_data();

  our $dtoks1 = ng_delimit($toks,$beg,$bos1);
  our $dtoks1_want = pdl(long,[-1,  1, -1,  1,  2, -1,  1,  2,  3, -1,  1,  2,  3,  4]);
  print "ng_delimit(1d,nDelim=1): ", (all($dtoks1==$dtoks1_want) ? "ok" : "NOT ok"), "\n";

  our $dtoks2 = ng_delimit($toks,$beg,$bos2);
  our $dtoks2_want = pdl(long,[-2,-1,  1, -2,-1,  1,  2, -2,-1,  1,  2,  3, -2,-1,  1,  2,  3,  4]);
  print "ng_delimit(1d,nDelim=2): ", (all($dtoks2==$dtoks2_want) ? "ok" : "NOT ok"), "\n";

  our $dtoks1_2d = ng_delimit($toks2d,$beg,$bos1);
  our $dtoks1_2d_want = pdl(long,[[-1,  1, -1,  1,  2, -1,  1,  2,  3, -1,  1,  2,  3,  4],
				  [-1, 10, -1, 10, 20, -1, 10, 20, 30, -1, 10, 20, 30, 40]]);
  print "ng_delimit(2d,nDelim=1): ", (all($dtoks1_2d==$dtoks1_2d_want) ? "ok": "NOT ok"), "\n";


  our $dtoks2_2d = ng_delimit($toks2d,$beg,$bos2);
  our $dtoks2_2d_want = pdl(long,[[-2,-1,  1, -2,-1,  1,  2, -2,-1,  1,  2,  3, -2,-1,  1,  2,  3,  4],
				  [-2,-1, 10, -2,-1, 10, 20, -2,-1, 10, 20, 30, -2,-1, 10, 20, 30, 40]]);
  print "ng_delimit(2d,nDelim=2): ", (all($dtoks2_2d==$dtoks2_2d_want) ? "ok": "NOT ok"), "\n";

  our $dtoks2_2d_sl = ng_delimit($toks2d,$beg->slice(",*2"),$bos2->slice(",*2"));
  our $dtoks2_2d_sl_want = $dtoks2_2d_want;
  print "ng_delimit(2d+slices,nDelim=2): ", (all($dtoks2_2d_sl==$dtoks2_2d_sl_want) ? "ok": "NOT ok"), "\n";

}
test_ng_delimit();

sub test_ng_undelimit {
  test_ng_data();
  our ($boffsets,$delims);

  our $dtoks1 = ng_delimit($toks,$beg,$bos1);
  our $udtoks1 = ng_undelimit($dtoks1,$beg,$bos1->dim(0));
  isok("ng_undelimit(toks:1d,nDelims:1)", all($udtoks1==$toks));

  our $dtoks2  = ng_delimit($toks,$beg,$bos2);
  our $udtoks2 = ng_undelimit($dtoks2,$beg,$bos2->dim(0));
  isok("ng_undelimit(toks:1d,nDelims:2)", all($udtoks2==$toks));


  our $dtoks1_2d  = ng_delimit($toks2d,$beg,$bos1);
  our $udtoks1_2d = ng_undelimit($dtoks1_2d,$beg,$bos1->dim(0));
  isok("ng_undelimit(toks:2d,offsets:1d,nDelims:1)", all($udtoks1_2d==$toks2d));

  our $dtoks2_2d  = ng_delimit($toks2d,$beg,$bos2);
  our $udtoks2_2d = ng_undelimit($dtoks2_2d,$beg,$bos2->dim(0));
  isok("ng_undelimit(toks:2d,offsets:1d,nDelims:2)", all($udtoks2_2d==$toks2d));

  our $dtoks2_2d_sl  = ng_delimit($toks2d,$beg->slice(",*2"),$bos2->slice(",*2"));
  our $udtoks2_2d_sl = ng_undelimit($dtoks2_2d_sl,$beg->slice(",*2"),$bos2->dim(0));
  isok("ng_undelimit(toks:2d,offsets:2d,nDelims:2)", all($udtoks2_2d_sl==$toks2d));
}
#test_ng_undelimit();

##---------------------------------------------------------------------
## DUMMY
##---------------------------------------------------------------------
foreach $i (0..3) {
  print "--dummy($i)--\n";
}

