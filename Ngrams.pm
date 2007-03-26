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
   qw(ng_cofreq ng_rotate),
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
## ng_cofreq()
=pod

=head2 ng_cofreq

=for sig

  Signature: (toks(@adims,N,NToks); %args)

  Returns: ([o]ngramids(@adims,N,NNgrams); int [o]ngramfreqs(NNgrams))

Keyword arguments (optional):

  norotate => $bool,                      ##-- if true, $toks() will NOT be rotated along $N
  boffsets => $boffsets(NBlocks)          ##-- block-offsets in $toks() along $NToks
  delims   => $delims(@adims,N,NDelims)   ##-- delimiters to splice in at block boundaries

Count co-occurrences (esp. N-Grams) over a token vector $toks.
This function really just wraps ng_delimit(), rotate(), _ng_qsortvec(), and rleND().

=cut

##-- WORKS
#$N=2;
#$NToks=5;
#@adims=qw(4 3);
#$adslice=join(',',map{"*$_"}@adims);
#$toks=sequence($NToks,@adims)->slice(",*$N")->mv(0,-1)->mv(0,-1);
#$beg=pdl(long,[0,$NToks]);
#$bos=pdl(long,[-1]);
#$dtoks=ng_delimit($toks->mv(-2,0),$beg->slice(",$adslice,*$N"),$bos->slice(",$adslice,*$N"))->mv(0,-2)

##-- same thing, 1-line:
#$N=2; $NToks=5; @adims=qw(4 3); $adslice=join(',',map{"*$_"}@adims); $toks=sequence($NToks,@adims)->slice(",*$N")->mv(0,-1)->mv(0,-1); $beg=pdl(long,[0,$NToks]); $bos=pdl(long,[-1]); $dtoks=ng_delimit($toks->mv(-2,0),$beg->slice(",$adslice,*$N"),$bos->slice(",$adslice,*$N"))->mv(0,-2) ##-- OK

##-- new dimensions:
#$N=2; $NToks=5; @adims=qw(3); $adslice=join(',',map{"*$_"}@adims); $toks=sequence($NToks)->slice("$adslice,*$N,:"); $beg=pdl(long,[0,$NToks]); $bos=pdl(long,[-1])->slice("$adslice,*$N,"); $dtoks=ng_delimit($toks->mv(-1,0),$beg->slice(",$adslice,*$N"),$bos->mv(-1,0))->mv(0,-1)

*PDL::ng_cofreq = \&ng_cofreq;
sub ng_cofreq {
  my ($toks,%args) = @_;
  ##
  ##-- sanity checks
  barf('Usage: ngrams($toks,%args)') if (!defined($toks));
  my @adims      = $toks->dims;
  my ($N,$NToks) = splice(@adims, $#adims-1, 2);
  ##
  ##-- splice in some delimiters (maybe)
  my ($dtoks);
  if (defined($args{boffsets}) && defined($args{delims})) {
    my $adslice = (@adims ? join(',', (map {"*$_"} @adims),'') : '');
    $dtoks = ng_delimit($toks->mv(-1,0),
			$args{boffsets}->slice(",${adslice}*$N"),
			$args{delims}->mv(-1,0),
		       )->mv(0,-1);
  } else {
    $dtoks = $toks;
  }
  ##
  ##-- rotate components (maybe)
  my $NDToks = $dtoks->dim(-1);
  my ($ngvecs);
  if ($args{norotate}) { $ngvecs=$dtoks; }
  else                 { $ngvecs=ng_rotate($dtoks); }
  ##
  ##-- sort 'em & count 'em
  my @ngvdims = $ngvecs->dims;
  $ngvecs     = $ngvecs->clump(-2)->_ng_qsortvec();
  my ($ngfreq,$ngelts) = rlevec($ngvecs);
  my $ngwhich          = which($ngfreq);
  ##
  ##-- reshape results (using @ngvdims)
  $ngelts = $ngelts->reshape(@ngvdims);
  ##
  ##.... and return
  return ($ngfreq->index($ngwhich), $ngelts->dice_axis(-1,$ngwhich));
}

##======================================================================
## N-Gram construction: rotation
=pod

=head2 ng_rotate

  Signature: (toks(@adims,N,NToks); [o]rtoks(@adims,N,NToks-N+1))

Create a co-occurrence matrix by rotating a (delimited) token vector $toks().
Returns a matrix $rtoks() suitable for passing to ng_cofreq().

=cut

*PDL::ng_rotate = \&ng_rotate;
sub ng_rotate {
  my ($toks,$rtoks) = @_;

  barf("Usage: ng_rotate (toks(NAttrs,N,NToks), [o]rtoks(NAttrs,N,NToks-N-1))")
    if (!defined($toks));

  my @adims = $toks->dims();
  $rtoks = zeroes($toks->type, @adims) if (!defined($rtoks));
  my $NToks = pop(@adims);
  my $N     = pop(@adims);
  my ($i);
  foreach $i (0..($N-1)) {
    $rtoks->dice_axis(-2,$i) .= $toks->dice_axis(-2,$i)->xchg(-1,0)->rotate(-$i)->xchg(0,-1);
  }
  $rtoks = $rtoks->xchg(-1,0)->slice("0:-$N")->xchg(-1,0);

  return $rtoks;
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

*PDL::rleND = \&rleND;
sub rleND {
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

*PDL::rldND = \&rldND;
sub rldND {
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
