package Oak::Web::HTML::Acronym;

use strict;
use Error qw(:try);
use base qw(Oak::Web::HTML::PhraseElement);

=head1 NAME

Oak::Web::HTML::Acronym - ACRONYM HTML Tag

=head1 DESCRIPTION

Insert an ACRONYM tag with some text inside

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::PhraseElement|Oak::Web::HTML::PhraseElement>

L<Oak::Web::HTML::Acronym|Oak::Web::HTML::Acronym>


=head1 PROPERTIES

The Oak::Web::HTML::Acronym object has the following properties:

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
	$self->set(type => "ACRONYM");
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
