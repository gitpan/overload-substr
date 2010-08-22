#!/usr/bin/perl -w

use strict;
use Test::More tests => 4 + 1;
use Test::NoWarnings;

package SimpleString;

use overload::substr substr => \&_substr;

sub new
{
   my $class = shift;
   my ( $str ) = @_;
   return bless {
      str => $str,
   }, $class;
}

my @substr_args;
my $substr_return;
sub _substr
{
   my $self = shift;
   @substr_args = @_;

   return $substr_return;
}

package main;

my $str = SimpleString->new( "Hello, world" );

$substr_return = "Hello";

is( substr( $str, 0, 5 ),
    "Hello",
    'substr extraction' );

is_deeply( \@substr_args,
           [ 0, 5 ],
           '@args to substr extraction' );

substr( $str, 0, 5, "Goodbye" );
is_deeply( \@substr_args,
           [ 0, 5, "Goodbye" ],
           '@args to substr replacement' );

TODO: {
   local $TODO = "LVALUE substr";

   substr( $str, 9, 0 ) = "cruel ";
   is_deeply( \@substr_args,
              [ 9, 0, "cruel " ],
              '@args to substr replacment by lvalue' );
}
