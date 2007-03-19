# -*- Mode: CPerl -*-
# t/01_rlevec.t: test rlevec/rldvec

$TEST_DIR = './t';
#use lib qw(../blib/lib ../blib/arch); $TEST_DIR = '.'; # for debugging

# load common subs
use Test;
do "$TEST_DIR/common.plt";
use PDL;
use PDL::Ngrams;

BEGIN { plan tests=>3, todo=>[]; }

## 1..2: test nnz
$p = pdl([[1,2],[1,2],[1,2],[3,4],[3,4],[5,6]]);

($pf,$pv)  = rlevec($p);
$pf_expect = pdl([3,2,1,0,0,0]);
$pv_expect = pdl([[1,2],[3,4],[5,6],[0,0],[0,0],[0,0]]);

isok("rlevec():counts",  all($pf==$pf_expect));
isok("rlevec():vectors", all($pv==$pv_expect));

## 3..3: test rldvec

$pd = rldvec($pf,$pv);
isok("rldvec()", all($pd==$p));

print "\n";
# end of t/01_rlevec.t

