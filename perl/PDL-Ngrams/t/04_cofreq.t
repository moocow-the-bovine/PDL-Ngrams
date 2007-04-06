# -*- Mode: CPerl -*-
# t/04_cofreq.t: test ng_cofreq

$TEST_DIR = './t';
#use lib qw(../blib/lib ../blib/arch); $TEST_DIR = '.'; # for debugging

# load common subs
use Test;
do "$TEST_DIR/common.plt";
use PDL;
use PDL::Ngrams;

BEGIN { plan tests=>4, todo=>[]; }

##--------------------------------------------------------------
## Base data
our $toks   = pdl(long,[1, 1,2, 1,2,3, 1,2,3,4   ]);
our $beg    = pdl(long,[0, 1,   3,     6         ]);
our $bos1   = pdl(long,[-1]);

our $atoks  = $toks->slice("*1,")->append($toks->slice("*1,")*10)->append($toks->slice("*1,")*100);
our $abos1  = $bos1->append($bos1*10)->append($bos1*100);
our $N      = 2;

##--------------------------------------------------------------
## ng_cofreq()

## 1..2: ng_cofreq: 1d token vector, N=2, +delim
($ngfreq,$ngelts) = ng_cofreq($toks->slice("*$N,"), boffsets=>$beg, delims=>$bos1->slice("*$N,"));

our $ngfreq_1d_n2_want = pdl(long,[4,1,3,1,2,1,1]);
our $ngelts_1d_n2_want = pdl(long,[[-1,1],[1,-1],[1,2],[2,-1],[2,3],[3,-1],[3,4]]);
isok("ng_cofreq(toks:1d,N:2,+delims):freq", all($ngfreq==$ngfreq_1d_n2_want));
isok("ng_cofreq(toks:1d,N:2,+delims):elts", all($ngelts==$ngelts_1d_n2_want));

## 3..4: ng_cofreq: 2d token vector, N=2, +delim
($ngfreq,$ngelts) = ng_cofreq($atoks->slice(",*$N,"), boffsets=>$beg, delims=>$abos1->slice(",*$N,*1"));

our $ngfreq_2d_n2_want = $ngfreq_1d_n2_want;
our $ngelts_2d_n2_want = ($ngelts_1d_n2_want
			  ->append($ngelts_1d_n2_want*10)
			  ->append($ngelts_1d_n2_want*100)
			  ->reshape($N,3,7)
			  ->xchg(0,1));
isok("ng_cofreq(toks:2d,N:2,+delims):freq", all($ngfreq==$ngfreq_2d_n2_want));
isok("ng_cofreq(toks:2d,N:2,+delims):elts", all($ngelts==$ngelts_2d_n2_want));


print "\n";
# end of t/04_cofreq.t

