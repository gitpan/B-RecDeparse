#!perl -T

use strict;
use warnings;

use Test::More tests => 4 * 4 + 4 * 2;

use B::Deparse;
use B::RecDeparse;

sub add ($$) { $_[0] + $_[1] }
sub mul { $_[0] * $_[1] }
sub fma { add mul($_[0], $_[1]), $_[2] }
sub wut { fma $_[0], 2, $_[1] }

my @br_args = ('', '-sCi0v1');
my @brd_args = ({ }, { deparse => undef }, { deparse => { } }, { deparse => [ ] });

my $br = B::Deparse->new();
my $reference = $br->coderef2text(\&wut);
my $i = 1;
for (@brd_args) {
 my $brd = B::RecDeparse->new(%$_, level => 0);
 my $code = $brd->coderef2text(\&wut);
 is($code, $reference, "empty deparse and level 0 does the same thing as B::Deparse ($i)");
 $code = eval 'sub ' . $code;
 is($@, '', "result compiles ($i)");
 is_deeply( [ defined $code, ref $code ], [ 1, 'CODE' ], "result compiles to a code reference ($i)");
 is($code->(1, 3), wut(1, 3), "result compiles to the good thing ($i)");
 ++$i;
}

my $br_opts = '-sCi0v1';
@brd_args = ({ deparse => $br_opts }, { deparse => [ $br_opts ] });
for (@brd_args) {
 $br = B::Deparse->new($br_opts);
 my $brd = B::RecDeparse->new(%$_, level => 0);
 my $code = $brd->coderef2text(\&wut);
 is($code, $br->coderef2text(\&wut), "B::RecDeparse->new(deparse => '$br_opts' ), level => 0) does the same thing as B::Deparse->new('$br_opts') ($i)");
 $code = eval 'sub ' . $code;
 is($@, '', "result compiles ($i)");
 is_deeply( [ defined $code, ref $code ], [ 1, 'CODE' ], "result compiles to a code reference ($i)");
 is($code->(1, 3), wut(1, 3), "result compiles to the good thing ($i)");
 ++$i;
}
