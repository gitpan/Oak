package Oak::Web::HTML::Button;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Button - A Button tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Button|Oak::Web::HTML::Button>


=head1 PROPERTIES

The Oak::Web::HTML::Button object has the  properties defined by W3C.

=head1 EVENTS

ev_onClick: When this button is clicked

=cut

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	if ($cgi->param($self->get('name'))) {
		$self->{__events__}{ev_onClick} = 1;
	}
	return 1;
}


sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "type",
	 "name",
	 "value",
	 "disabled",
	 "tabindex",
	 "accesskey",
	 "onfocus",
	 "onblur"
	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<BUTTON";
	print $self->print_html_attributes;
	print ">\n";
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
