package Oak::Web::HTML::Cite;

use strict;
use Error qw(:try);
use base qw(Oak::Web::HTML::PhraseElement);

=head1 NAME

Oak::Web::HTML::Cite - CITE HTML Tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::PhraseElement|Oak::Web::HTML::PhraseElement>

L<Oak::Web::HTML::Cite|Oak::Web::HTML::Cite>


=head1 PROPERTIES

The Oak::Web::HTML::Cite object has the following properties:

=over

=item caption

The text inside the tag

=item All other defined by W3C.

This component will use all the available properties following
the rules of HTML4.01

=back

=cut

sub load_initial_properties {
	my $self = shift;
	$self->set(type => "CITE");
}

1;

__END__

=head1 BUGS

Too early to determine. :)

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
