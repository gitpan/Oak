package Oak::AAS::AuthenticationError;

use strict;
use base qw(Error);

sub stringify {
	my $self = shift;
	my $mens = $self->{-text} || "unkown";
	return "Authentication Error: $mens";
}

1;
