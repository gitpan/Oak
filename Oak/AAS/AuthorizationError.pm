package Oak::AAS::AuthorizationError;

use base qw(Error);

sub stringify {
	my $err=shift;
	my $msg=$err->{-text} || "No message was specified";
	return "Authorization Error: $msg\n";
}

1;
