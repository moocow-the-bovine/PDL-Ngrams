# -*- Mode: CPerl -*-
# t/02_rotate.t: test ng_rotate

$TEST_DIR = './t';
#use lib qw(../blib/lib ../blib/arch); $TEST_DIR = '.'; # for debugging

# load common subs
use Test;
do "$TEST_DIR/common.plt";
use PDL;
use PDL::Ngrams;

BEGIN { plan tests=>3, todo=>[]; }

##--------------------------------------------------------------
## Base data
our $toks   = pdl(long,[1, 1,2, 1,2,3, 1,2,3,4   ]);
our $toks2d = $toks->slice("*1,")->append((10*$toks)->slice("*1,"));
our ($N);

##--------------------------------------------------------------
## ng_rotate()

## 1: rotate (1d token vector, N=2)
$N=2;
our $rtoks1d_n2      = ng_rotate($toks->slice("*$N,"));
our $rtoks1d_n2_want = pdl(long, [ [1,1],  [1,2],[2,1],  [1,2],[2,3],[3,1],  [1,2],[2,3],[3,4] ]);
isok("ng_rotate(toks:1d,N:2): ", all($rtoks1d_n2==$rtoks1d_n2_want));

## 2: rotate (1d token vector, N=3)
$N=3;
our $rtoks1d_n3      = ng_rotate($toks->slice("*$N,"));
our $rtoks1d_n3_want = pdl(long,[ [1,1,2],  [1,2,1],[2,1,2],  [1,2,3],[2,3,1],[3,1,2],  [1,2,3],[2,3,4] ]);
isok("ng_rotate(toks:1d,N:3): ", all($rtoks1d_n3==$rtoks1d_n3_want));

## 3: rotate (2d token vector, N=2)
$N=2;
our $rtoks2d_n2      = ng_rotate($toks2d->slice(":,*$N,:"));
#our $rtoks2d_n2_want = $rtoks1d_n2_want->cat($rtoks1d_n2_want*10)->mv(-1,0)
our $rtoks2d_n2_want = pdl(long, [ [[1,10],[1,10]],
				   [[1,10],[2,20]],[[2,20],[1,10]],
				   [[1,10],[2,20]],[[2,20],[3,30]],[[3,30],[1,10]],
				   [[1,10],[2,20]],[[2,20],[3,30]],[[3,30],[4,40]],
				 ]);
isok("ng_rotate(toks:2d,N:2): ", all($rtoks2d_n2==$rtoks2d_n2_want));

print "\n";
# end of t/02_rotate.t

