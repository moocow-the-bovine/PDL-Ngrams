# -*- Text -*-

+ Make sure that the pure-perl ngrams() routine is working sensibly
  - maybe figure out how to generalize this sensibly a la threading?
    : NO: do this if & when we need it...

+ get N-grams into PDL::CCS form, e.g. MUDL::PdlDist::Sparse2d
  - only for bigrams right now: anything else would need a better PDL::CCS
    (or maybe PDL::CCS::ND)

+ get Make build system running using PDL-ified N-grams and corpus buffers
  (MUDL::Corpus::Buffer::PdlTT)

+ figure out how the bejeebers to generalize the induction process
  from (k=1) to (k'=k+1)
  - issues:
    * independence and (2k+1)-construction: [for (k=2), this is the question: "bigrams or trigrams"?]
      - the answer "assume independence" is most attractive, because:
        + it helps to aleviate sparse data problems (data doesn't become as sparse as fast)
	+ [HYPOTHESIS]: it's actually justified (in the limit) for regular language models of order (k)
	+ it allows an immediate and intuitive generalization for the (k'=k+1) manipulations, since
	  ANY (k+1)-gram can be decomposed into A SINGLE PAIR of [possibly overlapping] (k)-grams, so:
	  ~ [BIGRAMS : k=1, (k+1)=2] :  w[1..2]  = w1 w2       ~ < w[1]   ,  w[2]     >
	  ~ [TRIGRAMS: k=2, (k+1)=3] :  w[1..3]  = w1 w2 w3    ~ < w[1..2],  w[2..3]  >
	  ~ [4-GRAMS : k=3, (k+1)=4] :  w[1..4]  = w1 w2 w3 w4 ~ < w[1..3],  w[2..4]  >
	    ...
	  ~ [K-GRAMS : k=k, (k+1)=k']:  w[1..k'] = w1 ... wk'  ~ < w[1..k],  w[2..k'] >
	+ SO, if we can count to 2, we can count to anything...
    * profiling, features, and data objects:
      - when, where, and what do we reduce to CLUSTERS ?
        + C_{k-1} as FEATURES for inducing C_k ?
 	+ C_{k-1} as COMPONENTS of (k-gram) data objects clustered at (k) ?
	  ~ if so, are ONLY the C_{k-1} relevant, or do we always take another look at words?
	    - if words are included, it would make sense to have EXACTLY ONE WORD per data object
	    - problems:
	      * interpretation: neighbor-directions & "alignment" of cluster with words
	      * forking algorithm: independent left- & right- clusterings (e.g. for bigrams)
	        for higher-order models; analagous to parallel clustering of PTA and STA (states? arcs? paths?)
	      * 