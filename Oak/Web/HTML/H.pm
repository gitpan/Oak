package Oak::Web::HTML::H;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Container);

=head1 NAME

Oak::Web::HTML::H - Base for Header components

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::HTML::H|Oak::Web::HTML::H>


=head1 PROPERTIES

The Oak::Web::HTML::H object has the following properties:

=over

=item level

The level of the header, from 1 to 6.

=item All other defined by W3C.

This component will use all the available properties following
the rules of HTML4.01

=back

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "align"
	);
}

sub start_container {
	my $self = shift;
	print "<H".($self->get('level') || "1");
	$self->print_html_attributes;
	print ">";
}

sub end_container {
	my $self = shift;
	print "</H".($self->get('level') || "1").">\n";
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
