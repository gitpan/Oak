package Oak::Web::Session;

use strict;
use base qw(Oak::Object);

=head1 NAME

Oak::Web::Session - Object that holds the session attributes

=head1 DESCRIPTION

This object is used by Oak::Web::Application to provide a Session
behavior. When you set a parameter for the Session of an application
this parameter will be passed as a cookie to the clients browser and
it will be available during the rest of the session.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Web::Session|Oak::Web::Session>


=head1 PROPERTIES

The properties of the session are the attributes of this object

=head1 METHODS

=over

=item constructor

The constructor is overwrited to retrieve the session attributes

=back

=cut

sub constructor {
	my $self = shift;
	require CGI::Cookie;
	my %cookies = fetch CGI::Cookie;
	foreach (keys %cookies) {
		$self->SUPER::set($cookies{$_}->name => $cookies{$_}->value);
	}		
	return $self->SUPER::constructor(@_);
}

=over

=item get_cookies(PARAMS)

Returns an array ref with the CGI::Cookie objects defining the
properties that were set in this iteration.

All the parameters passed to this function will be repassed on
the creation of the Cookies. Please see CGI::Cookie documentation
to see what parameters can be passed.

P.S.: The name and value properties are defined by Oak::Web::Session

=back

=cut

sub get_cookies {
	my $self = shift;
	my %params = @_;
	delete $params{-name} if exists $params{-name};
	delete $params{-value} if exists $params{-value};
	my $ar_cookies = [];
	require CGI::Cookie;
	foreach my $p ($self->_modified_cookies) {
		my $cookie = new CGI::Cookie
		  (
		   -name => $p,
		   -value => $self->get($p),
		   %params
		  ) || next;
		push @{$ar_cookies}, $cookie;
	}
	return $ar_cookies;
}

=over

=item mark_all_cookies

This function makes all the cookies to be sent to the client again.
This can be usefull to expire all the cookies of this session.

=back

=cut

sub mark_all_cookies {
	my $self = shift;
	$self->{__MODIFIED_COOKIES__} ||= {};
	foreach my $k ($self->get_property_array) {
		$self->{__MODIFIED_COOKIES__}{$k} = 1;
	}
	return 1;
}

sub set {
	my $self = shift;
	my %params = @_;
	$self->_modified_cookies(keys %params);
	return $self->SUPER::set(%params);
}

sub _modified_cookies {
	my $self = shift;
	my @params = @_;
	$self->{__MODIFIED_COOKIES__} ||= {};
	foreach my $k (@params) {
		$self->{__MODIFIED_COOKIES__}{$k} = 1;
	}
	return keys %{$self->{__MODIFIED_COOKIES__}};
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
