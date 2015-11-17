use ExtUtils::MakeMaker;
require "pdlmaker.plm";
pdlmaker_init();

##-- common prerequisites
my %prereq = (
	      'PDL' => 0,
	      'PDL::VectorValued::Version' => '1.0.3',    ##-- for rlevec(), rleND(), vv_qsortvec(), vv_indx_sig(), vv_indx_typedef()
	     );

##-- workaround for bogus cpantesters error messages
## + see http://sourceforge.net/p/pdl/mailman/message/34623263/ ("headaches with indirect PDL-related dependencies on cpantesters", 2015-11-16 13:16:44)
## + workaround: ensure working PDL::VectorValued at configure-time; return UNKNOWN otherwise
use version;
require 'PDL/VectorValued.pm'
  or die("$0: ERROR: could not require PDL/VectorValued.pm");
die("$0: ERROR: unsupported \$PDL::VectorValued::VERSION $PDL::VectorValued::VERSION (need at least $prereq{PDL::VectorValued::Version})")
  if (version->parse($PDL::VectorValued::VERSION) < version->parse($prereq{'PDL::VectorValued::Version'}));

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
