# -*- Mode: CPerl -*-
# File: t/common.plt
# Description: re-usable test subs for Math::PartialOrder
use Test;
$| = 1;

# isok($label,@_) -- prints helpful label
sub isok {
  my $label = shift;
  print "$label:\n";
  ok(@_);
}

# skipok($label,$skip_if_true,@_) -- prints helpful label
sub skipok {
  my ($label,$skip_if_true) = splice(@_,0,2);
  print "$label:\n";
  skip($skip_if_true,@_);
}

# ulistok($label,\@got,\@expect)
# --> ok() for unsorted lists
sub ulistok {
  my ($label,$l1,$l2) = @_;
  isok($label,join(',',sort(@$l1)),join(',',sort(@$l2)));
}

# cmp_dims($got_pdl,$expect_pdl)
sub cmp_dims {
  my ($p1,$p2) = @_;
  return $p1->ndims==$p2->ndims && all(pdl(long,[$p1->dims])==pdl(long,[$p2->dims]));
}

print "common.plt loaded.\n";

1;

