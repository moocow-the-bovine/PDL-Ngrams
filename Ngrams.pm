##-*- Mode: CPerl -*-
##
## File: PDL::Ngrams.pm
## Author: Bryan Jurish <moocow@ling.uni-potsdam.de>
## Description: high-level pure-perl N-Gram utilities

package PDL::Ngrams;
use PDL;
use PDL::Ngrams::ngutils;
use strict;

our @EXPORT_OK =
  (
   @PDL::Ngrams::ngutils::EXPORT_OK,
   ##-- more
  );
our %EXPORT_TAGS =
  (
   Func=>[@EXPORT_OK];
  );

our @ISA = qw(PDL::Exporter);

##======================================================================
## POD: headers
=pod

=head1 NAME

PDL::Ngrams - N-Gram utilities for PDL

=head1 SYNOPSIS

 use PDL;
 use PDL::Ngrams;

 ##---------------------------------------------------------------------
 ## ... stuff happens

=cut



1; ##-- make perl happy


##======================================================================
## POD: footers

##---------------------------------------------------------------------
=pod

=head1 ACKNOWLEDGEMENTS

Perl by Larry Wall.

PDL by Karl Glazebrook, Tuomas J. Lukka, Christian Soeller, and others.

=cut

##----------------------------------------------------------------------
=pod

=head1 KNOWN BUGS

Probably many.

=cut


##---------------------------------------------------------------------
=pod

=head1 AUTHOR

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>

=head2 Copyright Policy

Copyright (C) 2007, Bryan Jurish. All rights reserved.

This package is free software, and entirely without warranty.
You may redistribute it and/or modify it under the same terms
as Perl itself.

=head1 SEE ALSO

perl(1), PDL(3perl), PDL::Ngrams::ngutils(3perl)

=cut
