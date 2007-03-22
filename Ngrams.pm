##-*- Mode: CPerl -*-
##
## File: PDL::Ngrams.pm
## Author: Bryan Jurish <moocow@ling.uni-potsdam.de>
## Description: N-Gram utilities for PDL
##======================================================================

package PDL::Ngrams;
use strict;

our $VERSION = 0.02;

##======================================================================
## Export hacks
use PDL;
use PDL::Exporter;
use PDL::Ngrams::ngutils;
our @ISA = qw(PDL::Exporter);
our @EXPORT_OK =
  (
   (@PDL::Ngrams::ngutils::EXPORT_OK), ##-- inherited
   qw(ngrams),
   qw(rleND rldND),
  );
our %EXPORT_TAGS =
  (
   Func => [@EXPORT_OK],               ##-- respect PDL conventions (hopefully)
  );

##======================================================================
## pod: header
=pod

=head1 NAME

PDL::Ngrams - N-Gram utilities for PDL

=head1 SYNOPSIS

 use PDL;
 use PDL::Ngrams;

 ##---------------------------------------------------------------------
 ## Basic Data
 $toks = rint(10*random(10));

 ##---------------------------------------------------------------------
 ## ... stuff happens


=cut

##======================================================================
## Description
=pod

=head1 DESCRIPTION

PDL::Ngrams provides basic utilities for tracking N-grams over PDL vectors.

=cut

##======================================================================
## pod: Functions
=pod

=head1 FUNCTIONS

=cut

##======================================================================
## Run-Length Encoding/Decoding: n-dimensionl
=pod

=head1 Counting N-Grams over PDLs

=cut

##----------------------------------------------------------------------
## ngrams()
=pod

=head2 ngrams

=for sig

  Signature: (toks(N,NToks); int N; %args) ##-- general case, specifying components
  Signature: (toks(  NToks); int N; %args) ##-- simple case with only 1 component domain

  Returns: ([o]ngramids(N,NNgrams); int [o]ngramfreqs(NNgrams))

Keyword arguments (optional):

  boffsets => $boffsets(NBlocks)   ##-- gives block-offsets in $toks() vector
  delims   => $delims(NDelims)     ##-- specify delimiters to splice in at block boundaries

Count N-Grams over a token vector $toks.
This function really just wraps qsortvec(), ng_delimit(), and rleND().

B<CAVEAT INVOCATOR:>
Requires a working qsortvec(), which is broken in the stock
PDL v2.4.3.  Chris Marshall has submitted a patch to fix the
bug, which is available here (the patch, not the bug):

 http://sourceforge.net/tracker/index.php?func=detail&aid=1548824&group_id=612&atid=300612

=cut

*ngrams = \&PDL::ngrams;
sub PDL::ngrams {
  my ($toks,$N,%args) = @_;
  ##
  ##-- sanity check(s)
  barf('Usage: ngrams($toks,$N,%args)')
    if (!defined($toks) || !defined($N) || $N <= 0);
  barf('ngrams(): cannot handle multi-dimensional \$toks')
    if ($toks->ndims > 1 && ($toks->ndims != 2 || $toks->dim(0) != $N)); ##-- FIXME
  ##
  ##-- splice in some delimiters (maybe)
  my ($dtoks);
  if (defined($args{boffsets}) && defined($args{delims})) {
    $dtoks = ng_delimit($toks,$args{boffsets},$args{delims});
  } else {
    $dtoks = $toks;
  }
  ##
  ##-- get n-gram vector pdl
  $dtoks     = $dtoks->slice("*$N,") if ($dtoks->ndims == 1);
  my $NDToks = $dtoks->dim(-1);
  my $ngvecs = append(map {$dtoks->slice("($_)")->rotate(-$_)->slice("*1,")} (0..($N-1)));
  $ngvecs    = $ngvecs->slice(",0:-$N")->qsortvec;
  ##
  ##-- count 'em
  my ($ngfreq,$ngelts) = rleND($ngvecs);
  my $ngwhich          = $ngfreq->which();
  ##
  ##.... and return
  return ($ngfreq->index($ngwhich), $ngelts->dice_axis(-1,$ngwhich));
}


##======================================================================
## Run-Length Encoding/Decoding: n-dimensionl
=pod

=head1 Higher-Order Run-Length Encoding and Decoding

The following functions generalize the builtin PDL functions rle() and rld()
for higher-order "values".
They can be used to count N-grams from raw sorted vectors.

=cut

##----------------------------------------------------------------------
## rleND()
=pod

=head2 rleND

=for sig

  Signature: (data(@vdims,N); int [o]counts(N); [o]elts(@vdims,N))

Run-length encode a set of (sorted) n-dimensional values.

Generalization of rle() and rlevec():
given set of values $data, generate a vector $counts with the number of occurrences of each element
(where an "element" is a matrix of dimensions @vdims ocurring as a sequential run over the final dimension in $data),
and a set of vectors $elts containing the elements which begin a run.

Really just a wrapper for clump() and rlevec().

See also: PDL::Slices::rle, PDL::Ngrams::ngutils::rlevec

=cut

*rleND = \&PDL::rleND;
sub PDL::rleND {
  my $data   = shift;
  my @vdimsN = $data->dims;

  ##-- construct output pdls
  my $counts = $#_ >= 0 ? $_[0] : zeroes(long, $vdimsN[$#vdimsN]);
  my $elts   = $#_ >= 1 ? $_[1] : zeroes($data->type, @vdimsN);

  ##-- guts: call rlevec()
  rlevec($data->clump($#vdimsN), $counts, $elts->clump($#vdimsN));

  return ($counts,$elts);
}

##----------------------------------------------------------------------
## rldND()
=pod

=head2 rldND

=for sig

  Signature: (int counts(N); elts(@vdims,N); [o]data(@vdims,N);)

Run-length decode a set of (sorted) n-dimensional values.

Generalization of rld() and rldvec():
given a vector $counts() of the number of occurrences of each @vdims-dimensioned element,
and a set $elts() of @vdims-dimensioned elements, run-length decode to $data().

Really just a wrapper for clump() and rldvec().

See also: PDL::Slices::rld, PDL::Ngrams::ngutils::rldvec

=cut

*rldND = \&PDL::rldND;
sub PDL::rldND {
  my ($counts,$elts) = (shift,shift);
  my @vdimsN        = $elts->dims;

  ##-- construct output pdl
  my ($data);
  if ($#_ >= 0) { $data = $_[0]; }
  else {
    my $size      = $counts->sumover->max; ##-- get maximum size for Nth-dimension for small encodings
    my @countdims = $counts->dims;
    shift(@countdims);
    $data         = zeroes($elts->type, @vdimsN, @countdims);
  }

  ##-- guts: call rldvec()
  rldvec($counts, $elts->clump($#vdimsN), $data->clump($#vdimsN));

  return $data;
}


##======================================================================
## Delimit / Splice
=pod

=head1 Delimiter Insertion and Removal

The following functions can be used to add or remove delimiters to a PDL vector.
This can be useful to add or remove beginning- and/or end-of-word markers to rsp.
from a PDL vector, before rsp. after constructing a vector of N-gram vectors.

=cut

##----------------------------------------------------------------------
## ng_delimit()
=pod

=head2 ng_delimit

=for sig

  Signature: (toks(NToks); int boffsets(NBlocks); delims(NDelims); [o]dtoks(NDToks))

Add block-delimiters (e.g. BOS,EOS) to a vector of raw tokens.

See L<PDL::Ngrams::ngutils/"ng_delimit">.

=cut

##----------------------------------------------------------------------
## ng_undelimit()
=pod

=head2 ng_undelimit

  Signature: (dtoks(NDToks); int boffsets(NBlocks); int NDelims(); [o]toks(NToks))

Remove block-delimiters (e.g. BOS,EOS) from a vector of delimited tokens.

See L<PDL::Ngrams::ngutils/"ng_undelimit">.

=cut



1; ##-- make perl happy


##======================================================================
## pod: Functions: low-level
=pod

=head2 Low-Level Functions

Some additional low-level functions are provided in the
PDL::Ngrams::ngutils
package.
See L<PDL::Ngrams::ngutils> for details.

=cut

##======================================================================
## pod: Footer
=pod

=head1 ACKNOWLEDGEMENTS

perl by Larry Wall.

=head1 AUTHOR

Bryan Jurish E<lt>jurish@ling.uni-potsdam.deE<gt>

PDL by Karl Glazebrook, Tuomas J. Lukka, Christian Soeller, and others.

=head1 COPYRIGHT

Copyright (c) 2007, Bryan Jurish.  All rights reserved.

This package is free software.  You may redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), PDL(3perl), PDL::Ngrams::ngutils(3perl)

=cut
