package Oak::Web::HTML::Option;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Option - A Button tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Option|Oak::Web::HTML::Option>


=head1 PROPERTIES

select: This property says which select is the owner of this option.

The Oak::Web::HTML::Option object has the  properties defined by W3C.

=head1 EVENTS

When this option is selected ev_onSelect is dispatched

=cut

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	if ($self->{__owner__}->get_child($self->get('select'))->is_selected($self->get('value'))) {
		$self->{__events__}{ev_onSelect} = 1;
	}
	return 1;
}

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "selected",
	 "disabled",
	 "label",
	 "value"
	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<OPTION";
	if ($self->get("select") &&
	    $self->{__owner__}->get_child($self->get("select"))->is_selected($self->get('value'))) {
		print " SELECTED";
	}
	print $self->print_html_attributes;
	print ">".$self->get('label')."</OPTION>\n";
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
