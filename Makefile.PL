use ExtUtils::MakeMaker;
require "pdlmaker.plm";
pdlmaker_init();

##-- common prerequisites
my %prereq = (
	      'PDL' => 0,
	      'PDL::VectorValued::Version' => '0.07001',    ##-- for rlevec(), rleND(), vv_qsortvec(), vv_indx_sig(), vv_indx_typedef()
	     );
WriteMakefile(
	      NAME         => 'PDL::Ngrams',
	      VERSION_FROM => 'Ngrams/ngutils.pd',
	      ABSTRACT     => 'N-Gram utilities for PDL',
	      AUTHOR       => 'Bryan Jurish <moocow@cpan.org>',
	      PREREQ_PM    => {%prereq},
	      CONFIGURE_REQUIRES => {%prereq},
	      realclean => {
			    FILES => '*~ *.tmp README.txt',
			   },
	     );
