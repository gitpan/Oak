package Oak::Web::Additional::ActionLinkList;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Additional::SimpleList);

=head1 NAME

Oak::Web::Additional::ActionLinkList - Component to create a L<Oak::Web::Additional::SimpleList|Oak::Web::Additional::SimpleList> component which
items are, each one, an L<Oak::Web::Additional::ActionLink|Oak::Web::Additional::ActionLink>.

=head1 DESCRIPTION

This components outputs an indented list of L<Oak::Web::Additional::ActionLink|Oak::Web::Additional::ActionLink>.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::SimpleList|Oak::Web::Additional::SimpleList>

L<Oak::Web::Additional::ActionLink|Oak::Web::Additional::ActionLink>

=head1 PROPERTIES

=over

=item list

A string with the list of items. Each item in one line. The indentation is
made by the number of white spaces before the first character.

The item must have two fields, separated with a pipe (|), the first side is
the item id, and the second is the item text.

=item application

The base url for the link

=item origin

__owa_origin__ for the link. Defaults to the name of the owner component.

=item selected_item

The item that has been clicked.

=item target

the target for the link.

=back

=head1 EVENTS

=over

=item ev_onClick

When one of the links is clicked.

=back

=cut

sub format_item {
	my $self = shift;
	my ($item_id,$item) = split(/\|/, shift, 2);
	my $origin = $self->get('origin') || $self->{__owner__}->get('name');
	my $link = '<A HREF="'.$self->get('application').'?__owa_origin__='.$origin.'&'.$self->get('name').'='.$item_id.'"';
	if ($self->get('target')) {
		$link .= ' TARGET="'.$self->get('target').'"';
	}
	$link .= '>'.$item.'</A>';
	return $link;
}

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	if ($cgi->param($self->get('name'))) {
		$self->set(selected_item => $cgi->param($self->get('name')));
		$self->{__events__}{ev_onClick} = 1;
	}
	return 1;
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
