use ExtUtils::MakeMaker;
require "pdlmaker.plm";
pdlmaker_init();

WriteMakefile(
	      NAME         => 'PDL::Ngrams',
	      VERSION_FROM => 'Ngrams.pm',
	      ABSTRACT     => 'N-Gram utilities for PDL',
	      AUTHOR       => 'Bryan Jurish <moocow@ling.uni-potsdam.de>',
	      PREREQ_PM => {
			    'PDL' => '2.4.2',              ##-- ensure PDL-ability
			    'PDL::VectorValued' => '0',    ##-- for rlevec(), rleND(), vv_qsortvec()
			   },
	      realclean => {
			    FILES => '*~ *.tmp README.txt',
			   },
	     );
