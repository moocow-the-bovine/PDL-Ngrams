use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME         => 'PDL::Ngrams',
	      VERSION_FROM => 'Ngrams.pm',
	      ABSTRACT     => 'N-Gram utilities for PDL',
	      AUTHOR       => 'Bryan Jurish <moocow@ling.uni-potsdam.de>',
	      PREREQ_PM => {
			    'PDL' => '2.4.2',              ##-- ensure PDL-ability
			    'PDL::VectorValued' => '0.01', ##-- for rlevec(), rleND(), vv_qsortvec()
			   },
	      realclean => {
			    FILES => '*~ *.tmp README.txt',
			   },
	     );

sub MY::depend {
  package MY;
  my $inherited = shift->SUPER::depend(@_);
  if (1) {
    $inherited .= (
		   "\n\n"
		   ."dist: README.txt\n"
		   ."\n"
		   ."create_distdir: README.txt\n"
		   ."\n"
		   ."distcheck: README.txt\n"
		   ."\n"
		   ."manicheck: README.txt\n"
		   ."\n"
		  );
  }
  $inherited;
}

sub MY::special_targets {
  package MY;
  my $inherited = shift->SUPER::special_targets(@_);
  #$inherited =~ s/^(\.SUFFIXES\s*:.*)$/$1 .pod .pm .man .txt .html;/
  $inherited .=
"
.SUFFIXES: .pm .pod .rpod .man .txt .html

.pm.html:
\tpod2html --outfile \$@ \$<

.pm.txt:
\tpod2text \$< \$@

.pod.html:
\tpod2html --outfile \$@ \$<

.pod.txt:
\tpod2text \$< \$@

.rpod.html:
\tpod2html --outfile \$@ \$<

.rpod.txt:
\tpod2text \$< \$@

";
  $inherited;
}


sub MY::top_targets {
  package MY;
  my $inherited = shift->SUPER::top_targets(@_);
  $inherited;
}
