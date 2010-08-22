#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2010 -- leonerd@leonerd.org.uk

package overload::substr;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01_001';

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION );

=head1 NAME

C<overload::substr> - overload Perl's C<substr()> function

=head1 SYNOPSIS

 package My::Stringlike::Object;

 use overload::substr substr => sub {
    my $self = shift;
    if( @_ > 2 ) {
       $self->replace_substr( @_ );
    }
    else {
       return $self->get_substr( @_ );
    }
 };

 ...

=head1 DESCRIPTION

This module allows an object class to overload the C<substr> core function,
which Perl's C<overload> pragma does not allow by itself.

It is invoked similarly to the C<overload> pragma, being passed a single named
argument which should be a code reference to implement the C<substr> function.

 use overload::substr substr => \&SUBSTR;

The referred function will be invoked as per core's C<substr>; namely, it will
take the string to be operated on (which will be an object in this case), an
offset, optionally a length, and optionally a replacement.

 $str->SUBSTR( $offset );
 $str->SUBSTR( $offset, $length );
 $str->SUBSTR( $offset, $length, $replacement );

In each case, whatever it returns will be the return value of the C<substr>
function that invoked it.

=cut

sub import
{
   my $class = shift;
   my %args = @_;

   my $package = caller;

   my $substr = delete $args{substr};
   defined $substr or $substr = "_substr";

   keys %args and
      croak "Unrecognised extra keys to $class: " . join( ", ", sort keys %args );

   # This somewhat steps on overload.pm 's toes
   no strict 'refs';
   *{$package."::(substr"} = $substr;
}

# Keep perl happy; keep Britain tidy
1;

__END__

=head1 TODO

=over 8

=item *

Allow bare method names as well as CODE refs

=item *

Implement LVALUE C<substr( $str, $offset, $length ) = $replacement>.

=back

=head1 ACKNOWLEDGEMENTS

With thanks to Matt S Trout <mst@shadowcat.co.uk> for suggesting the
possibility, and Joshua ben Jore <jjore@cpan.org> for the inspiration by way
of L<UNIVERSAL::ref>.

=head1 AUTHOR

Paul Evans <leonerd@leonerd.org.uk>
