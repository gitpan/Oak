package Oak::Action;

use strict;
use base qw(Oak::Component);

=head1 NAME

Oak::Action - Component that representates controller actions

=head1 DESCRIPTION

This component is to be used as a Action inside a Controller component.
It does nothing except dispatching his ev_onCall event.

=head1 HIERARCHY

  L<Oak::Object|Oak::Object>

  L<Oak::Persistent|Oak::Persistent>

  L<Oak::Component|Oak::Component>

  L<Oak::Action|Oak::Action>

=head1 EVENTS

=over

=item ev_onCall

Dispatched when this action is called.

=back

=head1 METHODS

=over

=item call

Call the action to dispatch the event

=back

=cut

sub call {
	my $self = shift;
	$self->dispatch('ev_onCall');
	return 1;
}


1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
Aguimar Mendonca Neto <aguimar@email.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
