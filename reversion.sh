#!/bin/bash

## + requires perl-reversion from Perl::Version (debian package libperl-version-perl)
## + example call:
##    ./reversion.sh -bump -dryrun

exec perl-reversion "$@" Ngrams.pm Ngrams/ngutils.pd


