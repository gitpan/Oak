package Oak::Web::Additional::MaskedInput;

use strict;
use Error qw(:try);
use base qw(Oak::Web::HTML::Input);

=head1 NAME

Oak::Web::Additional::MaskedInput - Component to create a input with mask check

=head1 DESCRIPTION

This components apply a regexp specified by the mask attribute in the check_syntax function.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Input|Oak::Web::HTML::Input>

L<Oak::Web::Additional::MaskedInput|Oak::Web::Additional::MaskedInput>

=head1 PROPERTIES

=over

=item mask

string containing the regexp to be applied (without the /s)

=item required

If true, then the field must be filled, else not.

=back

=cut


sub check_syntax {
	my $self = shift;
	if (!$self->get('value') && $self->get('required')) {
		$self->mark_error;
		throw Oak::Error::ParamsMissing;
	} elsif (!$self->get('value') && !$self->get('required')) {
		return 1;
	} else {
		my $regexp = $self->get('mask');
		if ($self->get('value') !~ /$regexp/) {
			$self->mark_error;
			throw Oak::Web::Additional::MaskedInput::Error;
		}
		return 1;
	}
}

=head1 EXCEPTIONS

=over

=item Oak::Web::Additional::MaskedInput::Error

An invalid value was found.

=back

=cut

package Oak::Web::Additional::MaskedInput::Error;

use base qw (Error);

sub stringify {
	return "Invalid String";
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
