package Oak::AAS::Service;

use base qw(Oak::Object);
use strict;

=head1 NAME

Oak::AAS::Service - Abstract class that defines the interface for AAS services

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::AAS::Service|Oak::AAS::Service>

=head1 DESCRIPTION

This is the base class for all the AAS services. This class describes the functionality of any
service.

=head1 METHODS

=over

=item constructor($params)

Must create the object and store the params it needs to work. Must throw an error if something
goes wrong. The params must be a single string.

=back

=cut

sub constructor {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}

=over

=item start_session(user,password)

Must start the session and return a unique id or false.

=back

=cut

sub start_session {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}

=over

=item validate_session(user,sessionid)

Check if this is a valid session, return a boolean value (1=>success).

=back

=cut

sub validate_session {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}

=over

=item end_session(user,sessionid)

End this session

=back

=cut

sub end_session {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}

=over

=item is_allowed(user,uri)

Return a true value if this user have access to this uri false if not.

=back

=cut

sub is_allowed {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}


=over

=item grant(user,uri)

Grant user the access to uri.

=back

=cut

sub grant {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}


=over

=item deny(user,uri)

Make the uri denied to the user

=back

=cut

sub deny {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}

=over

=item list_uri

return an array with the available uri

=back

=cut

sub list_uri {
	my $self = shift;
	die "Abstract method not implemented in ".ref $self;
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2003
Oktiva <http://www.oktiva.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
