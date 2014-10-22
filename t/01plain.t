#!/usr/bin/perl -w

use strict;
use Test::More tests => 4 + 1;
use Test::NoWarnings;

BEGIN {
   require overload::substr;
   # no import
};

is( substr( "Hello, world", 0, 5 ),
    "Hello",
    'substr extraction on constant' );

my $var = "Hello, world";
is( substr( $var, 0, 5 ),
    "Hello",
    'substr extraction on variable' );

substr( $var, 0, 5, "Goodbye" );
is( $var,
    "Goodbye, world",
    'substr manipulation by replacement' );

substr( $var, 9, 0 ) = "cruel ";
is( $var,
    "Goodbye, cruel world",
    'substr manipulation by lvalue' );
