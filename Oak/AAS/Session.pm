package Oak::AAS::Session;
use Oak::AAS::AuthorizationError;

use strict;
use base qw(Oak::Object);

=head1 NAME

Oak::AAS::Session - Authentication and Authorization Service Session

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::AAS::Session|Oak::AAS::Session>

=head1 DESCRIPTION

This class implements the Client side for the Oak Authentication and Authorization Service.

=head1 PROPERTIES

=over

=item service

The service to be consulted.
composed by:

  "aas_service;params"

Where:

  aas_service => One of the AAS services See L<Oak::AAS::Service|Oak::AAS::Service> for
                 information about services.
  params => Parameters to the aas service

The AAS Service is instanciated only once, after that a cache copy will be used.

=item user

The user login

=item session_id

The unique id of this session

=back

=head1 METHODS

=over

=item constructor(service => $sevice, user => $user)

Create a Session using the passed service and user.

=back

=cut

sub constructor {
	my $self = shift;
	my %params = @_;
	my $service = $params{service};
	$self->set
	  (
	   service => $service,
	   user => $params{user}
	  );
	unless ($Oak::AAS::Session::SERVICE_CACHE{$service}) {
		my ($servicename, $params) = (split(/;/,$service,2));
		eval "require $servicename";
		$self->{service} = $Oak::AAS::Session::SERVICE_CACHE{$service} = $servicename->new($params);		
	} else {
		$self->{service} = $Oak::AAS::Session::SERVICE_CACHE{$service};
	}
}

=over

=item start(user => $login, password => $passwd);

Check user and password and start a new session. The session id will be defined in the
session_id property. Throws an Oak::AAS::AuthenticationError if the password is invalid

=back

=cut

sub start {
	my $self = shift;
	my %params = @_;
	my $sid;
	if ($sid = $self->{service}->start_session($params{user}, $params{password})) {
		$self->set(session_id => $sid, user => $params{user});
		return $sid;
	} else {
		use Oak::AAS::AuthenticationError;
		throw Oak::AAS::AuthenticationError;
	}
}

=over

=item validate(user => $login, session_id => $sid);

Check if this is a valid session. Throws an Oak::AAS::AuthenticationError if not.

=back

=cut

sub validate {
	my $self = shift;
	my %params = @_;
	if ($self->{service}->validate_session($params{user}, $params{session_id})) {
		$self->set(session_id => $params{session_id}, user => $params{user});
		return 1;
	} else {
		use Oak::AAS::AuthenticationError;
		throw Oak::AAS::AuthenticationError;
	}
}

=over

=item end()

End this session, the session_id will be no longer valid.

=back

=cut

sub end {
	my $self = shift;
	$self->{service}->end_session($self->get('user'),$self->get('session_id'));
}

=over

=item restricted $sessionobj "/path/to/a/service", sub { "do_something" }

Test if the current user is allowed to access the specified service. If so, the block will be executed.
Else an Oak::AAS::AuthorizationError will be thrown.

The syntax is:

  restricted $session "/service", sub {
	  # do something;
	  print "Hello World!";
  }; # DO NOT FORGET THE ;

=back

=cut

sub restricted ($;$;&) {
	my $self = shift;
	my $uri = shift;
	my $code = shift;
	if ($self->{service}->is_allowed($self->get('user'),$uri)) {
		&$code;
	} else {
		use Oak::AAS::AuthorizationError;
		throw Oak::AAS::AuthorizationError;
	}
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2003
Oktiva <http://www.oktiva.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


