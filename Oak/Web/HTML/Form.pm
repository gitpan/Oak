package Oak::Web::HTML::Form;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Container);

=head1 NAME

Oak::Web::HTML::Form - A form for submission

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::HTML::Form|Oak::Web::HTML::Form>


=head1 PROPERTIES

The Oak::Web::HTML::Form object has the following properties:

=over

=item action

Where to points the form to

=item method

POST or GET

=back

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "action",
	 "method",
	 "enctype",
	 "accept",
	 "name",
	 "onsubmit",
	 "onreset",
	 "accept-charset"
	);
}

sub start_container {
	my $self = shift;
	print "<FORM";
	print $self->print_html_attributes;
	print ">\n";
	print "<INPUT TYPE=\"HIDDEN\" NAME=\"__owa_origin__\" VALUE=\"".$self->{__owner__}->get('name')."\">\n";
}

sub end_container {
	print "</FORM>\n";
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
