package Oak::Web::TopLevel;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Container);

=head1 NAME

Oak::Web::TopLevel - Top level component of a web application

=head1 DESCRIPTION

This class is the base for top level components of a web application.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::TopLevel|Oak::Web::TopLevel>


=head1 EVENTS

=over

=item ev_onMessage

This event is fired just before the receive_cgi...
The CGI object is available at $self->{__cgi__} during this event.

=item ev_onSyntaxError

This event is launched when some "check_syntax" has failed.  If you do syntax check, you probably
wants to define this event.

=item ev_onUncaughtError

This event is launched when some error occours when dispatching the events of the child components.
If this is not set and an uncaught error occours, the error will be propagated.

=back

=head1 METHODS

=over

=item message(NAME => VALUE)

receives a message from the application.
In this module the only message is POST which receives the CGI object.

=back

=cut

sub message {
	my $self = shift;
	my %parms = @_;
	if ($parms{POST}) {
		my $cgi = $parms{POST};
		my $err = 0;
		$self->{__cgi__} = $cgi;
		$self->dispatch('ev_onMessage');
		delete $self->{__cgi__};
		foreach my $k ($self->list_childs) {
			my $child = $self->get_child($k);
			$child->receive_cgi($cgi);
		}
		try {
			foreach my $k ($self->list_childs) {
				my $child;
				my $r = eval {
					$child = $self->get_child($k);
					return 1;
				};
				if (!$r) {
					warn "Component $k was hard-freed";
					next;
				} else {
					$child->dispatch_all;
				}
			}
		} catch Oak::Web::TopLevel::Error::Syntax with {
			my $err = shift;
			$self->dispatch('ev_onSyntaxError');
			$self->{BAG} = {} unless ref $self->{BAG} eq "HASH";
			$self->show(%{$self->{BAG}});
		} otherwise {
			my $err = shift;
			if ($self->get('ev_onUncaughtError')) {
				$self->dispatch('ev_onUncaughtError');
			} else {
				throw $err;
			}
		};
	}
	return 1;
}

=over

=item check_syntax(NAME,NAME,NAME,NAME)

Check the syntax of the components.
If some exception occours, the name of the
component that generated the exception will be added
in $self->{__ERRORS__}{name} = {error} and a
Oak::Web::Page::Error::Syntax will be thrown.

=back

=cut

sub check_syntax {
	my $self = shift;
	my @names = shift;
	my $err = 0;
	foreach my $k (@names) {
		my $child = $self->get_child($k);
		try {
			$child->check_syntax;
		} otherwise {
			my $e = shift;
			$err = 1;
			$self->{__ERRORS__}{$k} = $e->stringify;
		}
	}
	if ($err) {
		throw Oak::Web::TopLevel::Error::Syntax;
	} else {
		return 1;
	}
}

=head1 EXCEPTIONS

The following exceptions are introduced by Oak::Component

=over

=item Oak::Web::TopLevel::Error::Syntax

This error is thrown by check_syntax telling that some test was wrong.

=back

=cut

package Oak::Web::TopLevel::Error::Syntax;
use base qw (Error);

sub stringify {
	return "Syntax Error";
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
