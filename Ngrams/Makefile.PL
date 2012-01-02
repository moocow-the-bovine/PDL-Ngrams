use PDL::Core::Dev;
use ExtUtils::MakeMaker;
PDL::Core::Dev->import();
require "../pdlmaker.plm";

$package = ["ngutils.pd","Utils","PDL::Ngrams::Utils"];
%hash = pdlmaker_init($package);

$hash{AUTHOR} = 'Bryan Jurish';
$hash{ABSTRACT} = 'Low-level N-Gram utilities for PDL';
$hash{VERSION_FROM} = 'ngutils.pd';
$hash{PREREQ_PM}{PDL} = '2.4.2'; ##-- ensure PDL-ability
push(@{$hash{LIBS}}, '-lm');
#$hash{INC} .= '';
$hash{DIR} = [];
#$hash{OBJECT} .= '';
$hash{realclean}{FILES} .= '*~ *.tmp README.txt';

WriteMakefile(%hash);
