package Oak::Web::Additional::UsernameField;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Additional::MaskedInput);

=head1 NAME

Oak::Web::Additional::UsernameField - Component to create a username field

=head1 DESCRIPTION

This component creates a username field. The input will have the size of 8
by default. And will accept only [a-zA-Z0-9\.\_\-].

The type of the input *is* text.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Input|Oak::Web::HTML::Input>

L<Oak::Web::Additional::MaskedInput|Oak::Web::Additional::MaskedInput>

L<Oak::Web::Additional::UsernameField|Oak::Web::Additional::UsernameField>

=head1 PROPERTIES

=over

=item required

If true, then the field must be filled, else not.

=back

=cut

sub constructor {
	my $self = shift;
	my %params = @_;
	if (ref $params{RESTORE} eq "HASH") {
		$params{RESTORE}{size} ||= "8";
		$params{RESTORE}{mask} = '^[a-zA-Z0-9\.\_\-]+$';
		$params{RESTORE}{type} = 'text';
	}
	$self->SUPER::constructor(%params);
}

=head1 EXCEPTIONS

=over

=item Oak::Web::Additional::UsernameField::Error::InvalidUsername

An invalid date was found.

=back

=cut

package Oak::Web::Additional::UsernameField::Error::InvalidUsername;

use base qw (Error);

sub stringify {
	return "Invalid Username";
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
