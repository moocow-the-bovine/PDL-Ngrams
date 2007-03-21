##------------------------------------------------------
## ng_nblocks()
pp_def('ng_nblocks',
       Pars => 'dtoks(NDToks); delims(NDelims); int [o]nblocks()',
       Code =>
<<'EOC',
 int szNDToks=$SIZE(NDToks), szNDelims=$SIZE(NDelims);
 int ndtoki=0,delimi;
 $nblocks()=0;
 for (; ndtoki<szNDToks; ) {
   for (delimi=0;
	$dtoks(NDToks=>ndtoki)==$delims(NDelims=>delimi) && ndtoki<szNDToks && delimi<szNDelims;
	ndtoki++, delimi++)
     { ; }
   if (delimi==szNDelims) {
     $nblocks()++;
     continue;
   }
   ndtoki++;
 }
EOC
       Doc=><<'EOD',
Count the number of delimited blocks in a delimited token vector.

EOD
);


##---------------------------------------------------------------------
## test: rlevec, rldvec: native: BUGGY

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
#test_rlevec_native();

