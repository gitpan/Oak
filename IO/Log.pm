package Oak::IO::Log;

use strict;
use base qw(Oak::Component);

=head1 NAME

Oak::IO::Log - Component that create a log output

=head1 DESCRIPTION

This component can be used, usually into a DataModule to
enable the programmer doing log output.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::IO::Log|Oak::IO::Log>


=head1 PROPERTIES

This is a abstract class, that is used as base for specific
log types.

=head1 METHODS

=over

=item log(MESSAGE)

This class introduces the log message. But, as a base class,
it just warns the message.

=back

=cut

sub log {
	my $self = shift;
	my $message = shift;
	warn $message
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


