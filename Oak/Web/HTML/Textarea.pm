package Oak::Web::HTML::Textarea;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Textarea - A textarea component

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Textarea|Oak::Web::HTML::Textarea>


=head1 PROPERTIES

The text property is the text that will appear in the textarea

The Oak::Web::HTML::Textarea object has the properties defined by W3C

=head1 EVENTS

When the text of the Textarea changes, the event ev_onChange is dispatched.

=cut

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	my $oldtext = $self->get('text');
	$self->set('text' => $cgi->param($self->get('name')));
	if ($oldtext ne $self->get('text')) {
		$self->{__events__}{ev_onChange} = 1;
	}
	return 1;
}

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "name",
	 "rows",
	 "cols",
	 "disabled",
	 "readonly",
	 "tabindex",
	 "accesskey",
	 "onfocus",
	 "onblur",
	 "onselect",
	 "onchange"
	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<TEXTAREA";
	print $self->print_html_attributes;
	print ">\n".$self->get('text')."</TEXTAREA>\n";
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
