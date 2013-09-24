use ExtUtils::MakeMaker;
require "pdlmaker.plm";
pdlmaker_init();

##-- common prerequisites
my %prereq = (
	      'PDL' => 0,
	      'PDL::VectorValued' => 0, #'0.07.000',    ##-- for rlevec(), rleND(), vv_qsortvec(), vv_indx()
	     );
WriteMakefile(
	      NAME         => 'PDL::Ngrams',
	      VERSION_FROM => 'Ngrams.pm',
	      ABSTRACT     => 'N-Gram utilities for PDL',
	      AUTHOR       => 'Bryan Jurish <moocow@cpan.org>',
	      PREREQ_PM    => {%prereq},
	      CONFIGURE_REQUIRES => {%prereq},
	      realclean => {
			    FILES => '*~ *.tmp README.txt',
			   },
	     );
