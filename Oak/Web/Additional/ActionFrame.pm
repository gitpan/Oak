package Oak::Web::Additional::ActionFrame;

use strict;
use Error qw(:try);
use base qw(Oak::Web::HTML::Frame);

=head1 NAME

Oak::Web::Additional::ActionFrame - A frame associated with an action

=head1 DESCRIPTION

A frame that dispatch an ev_onLoad.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Frame|Oak::Web::HTML::Frame>

L<Oak::Web::Additional::ActionFrame|Oak::Web::Additional::ActionFrame>


=head1 PROPERTIES

The Oak::Web::HTML::Frame object has the properties defined by W3C.
but the property application and the property params overrides
the src property.

=over

=item application

The url of this web application

=item params

Another params (in URL encoded format) to add to the link

=back

=head1 EVENTS

=over

=item ev_onLoad

This event is dispatched when this frame is loaded.

=back

=cut

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	if ($cgi->param($self->get('name'))) {
		$self->{__events__}{ev_onLoad} = 1;
	}
	return 1;
}



sub show {
	my $self = shift;
	$self->set
	  (
	   'src' =>
	   $self->get('application').
	   '?__owa_origin__='.$self->{__owner__}->get('name').'&'.
	   $self->get('name').'=true&'.$self->get('params')
	  );
	$self->SUPER::show;
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
