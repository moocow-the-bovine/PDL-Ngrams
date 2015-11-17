# -*- Mode: CPerl -*-
# t/01_delimit.t: test ng_delimit(), ng_undelimit()

$TEST_DIR = './t';
#use lib qw(../blib/lib ../blib/arch); $TEST_DIR = '.'; # for debugging

# load common subs
use Test;
do "$TEST_DIR/common.plt";
use PDL;
use PDL::Ngrams;

BEGIN { plan tests=>10, todo=>[]; }

##--------------------------------------------------------------
## Base data
our $toks   = pdl(long,[1, 1,2, 1,2,3, 1,2,3,4   ]);
our $beg    = pdl(long,[0, 1,   3,     6         ]);
our $toks2d = $toks->slice("*1,")->append((10*$toks)->slice("*1,"))->xchg(0,1);
our $bos1   = pdl(long,[-1]);
our $bos2   = pdl(long,[-2,-1]);

##--------------------------------------------------------------
## ng_delimit()

## 1: delimit (1d token vector, 1 delimiter)
our $dtoks1 = ng_delimit($toks,$beg,$bos1);
our $dtoks1_want = pdl(long,[-1,  1, -1,  1,  2, -1,  1,  2,  3, -1,  1,  2,  3,  4]);
isok("ng_delimit(toks:1d,nDelim:1): ", all($dtoks1==$dtoks1_want));

## 2: delimit (1d token vector, 2 delimiters)
our $dtoks2 = ng_delimit($toks,$beg,$bos2);
  our $dtoks2_want = pdl(long,[-2,-1,  1, -2,-1,  1,  2, -2,-1,  1,  2,  3, -2,-1,  1,  2,  3,  4]);
isok("ng_delimit(toks:1d,nDelim:2): ", all($dtoks2==$dtoks2_want));

## 3: delimit (2d token vector, 1d offsets & delmiters, 1 delimiter)
our $dtoks1_2d = ng_delimit($toks2d,$beg,$bos1);
our $dtoks1_2d_want = pdl(long,[[-1,  1, -1,  1,  2, -1,  1,  2,  3, -1,  1,  2,  3,  4],
				[-1, 10, -1, 10, 20, -1, 10, 20, 30, -1, 10, 20, 30, 40]]);
isok("ng_delimit(toks:2d,offsets:1d,nDelim:1): ", all($dtoks1_2d==$dtoks1_2d_want));

## 4: delimit (2d token vector, 1d offsets & delimiters, 2 delimiters)
our $dtoks2_2d = ng_delimit($toks2d,$beg,$bos2);
our $dtoks2_2d_want = pdl(long,[[-2,-1,  1, -2,-1,  1,  2, -2,-1,  1,  2,  3, -2,-1,  1,  2,  3,  4],
				  [-2,-1, 10, -2,-1, 10, 20, -2,-1, 10, 20, 30, -2,-1, 10, 20, 30, 40]]);
isok("ng_delimit(toks:2d,offsets:1d,nDelim=2): ", all($dtoks2_2d==$dtoks2_2d_want));

## 5: delimit (2d token vector, 2d offsets & delimiters, 2 delimiters)
our $dtoks2_2d_sl = ng_delimit($toks2d,$beg->slice(",*2"),$bos2->slice(",*2"));
our $dtoks2_2d_sl_want = $dtoks2_2d_want;
isok("ng_delimit(toks:2d,offsets:2d,nDelim=2): ", all($dtoks2_2d_sl==$dtoks2_2d_sl_want));

##--------------------------------------------------------------
## ng_undelimit()

## 6
#our $dtoks1 = ng_delimit($toks,$beg,$bos1);
our $udtoks1 = ng_undelimit($dtoks1,$beg,$bos1->dim(0));
isok("ng_undelimit(toks:1d,nDelims:1)", all($udtoks1==$toks));

## 7
#our $dtoks2  = ng_delimit($toks,$beg,$bos2);
our $udtoks2 = ng_undelimit($dtoks2,$beg,$bos2->dim(0));
isok("ng_undelimit(toks:1d,nDelims:2)", all($udtoks2==$toks));

## 8
#our $dtoks1_2d  = ng_delimit($toks2d,$beg,$bos1);
our $udtoks1_2d = ng_undelimit($dtoks1_2d,$beg,$bos1->dim(0));
isok("ng_undelimit(toks:2d,offsets:1d,nDelims:1)", all($udtoks1_2d==$toks2d));

## 9
#our $dtoks2_2d  = ng_delimit($toks2d,$beg,$bos2);
our $udtoks2_2d = ng_undelimit($dtoks2_2d,$beg,$bos2->dim(0));
isok("ng_undelimit(toks:2d,offsets:1d,nDelims:2)", all($udtoks2_2d==$toks2d));

## 10
#our $dtoks2_2d_sl  = ng_delimit($toks2d,$beg->slice(",*2"),$bos2->slice(",*2"));
our $udtoks2_2d_sl = ng_undelimit($dtoks2_2d_sl,$beg->slice(",*2"),$bos2->dim(0));
isok("ng_undelimit(toks:2d,offsets:2d,nDelims:2)", all($udtoks2_2d_sl==$toks2d));


print "\n";
# end of t/01_delimit.t

