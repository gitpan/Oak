package Oak::Controller;

use strict;
use base qw(Oak::Component);

=head1 NAME

Oak::Controller - Base class for the business logic tier

=head1 DESCRIPTION

This class is the base class for the business logic tier.
This is the second of the three layers model.

=head1 HIERARCHY

  L<Oak::Object|Oak::Object>

  L<Oak::Persistent|Oak::Persistent>

  L<Oak::Component|Oak::Component>

  L<Oak::Controller|Oak::Controller>

=head1 PROPERTIES

=over

=item transaction_io

A comma separated list of IO objects that support the begin_work, commit and rollback
functions used by this controller and that have transaction support. This class
will start the transaction before the action, rollback if some exception raises and
commit if everything goes fine.

=item authenticable

Boolean, defines if this module will implement authentication.

=back

=head1 EVENTS

=over

=item ev_onMessage

Dispatched when some message is called.

=back

=head1 METHODS

=over

=item message(NAME, PARAM => VALUE, PARAM => VALUE)

Call the action in the component NAME with the other params.
The other params are set in the $self->{BAG} variable.
This function returns the BAG after the modifications.

=back

=cut

sub message {
	my $self = shift;
	my $name = shift;
	my %params = @_;
	$self->{BAG} = \%params;
	my @ios;
	if ($self->get('transaction_io')) {
		my @ios = split(/,/, $self->get('transaction_io'));
	}
	foreach my $i (@ios) {
		$i->begin_work;
	}
	$self->dispatch('ev_onMessage');
	$self->authenticate(%params);
	my $action = $self->get_child($name);
	my $result = eval {
		$action->call;
		return 1;
	};
	unless ($result) {
		foreach my $i (@ios) {
			$i->rollback;
		}
		my $e = Error::prior();
		throw $e if $e;
		$e = $@;
		die $@;
	};
	if ($self->get('transaction_io')) {
		foreach my $i (@ios) {
			$i->commit;
		}
	}
	return $self->{BAG}
}

=over

=item authenticate(PARAM => VALUE, PARAM => VALUE)

If this class is authenticable this methd is called to verify if the user
is authenticated. If it doesnt, throw an Oak::Controller::Error::Auth

=back

=cut

sub authenticate {
	my $self = shift;
	if ($self->get('authenticable')) {
		throw Oak::Controller::Error::Auth;
	}
	# do nothing
	return 1;
}

=head1 EXCEPTION HANDLING

=over

=item Oak::Controller::Error::Auth

Will be thrown if an authentication error is found

=back

=cut

package Oak::Controller::Error::Auth;

use base qw(Error);

sub stringify {
	"Authentication Error";
}

=over

=item Oak::Controller::Error

An exception that must be used for generic Controller Errors

=back

=cut

package Oak::Controller::Error;

use base qw(Error);

sub stringify {
	"Controller Error"
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
