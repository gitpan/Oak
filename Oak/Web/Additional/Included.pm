package Oak::Web::Additional::Included;

use strict;
use Error qw(:try);
use base qw(Oak::Web::TopLevel);

=head1 NAME

Oak::Web::Additional::Included - Top level component but not a page

=head1 DESCRIPTION

This class is a container to be used as a included top-level component.
This component can receive posts. This component just overrides the
start_container and the end_container methods to print nothing.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::TopLevel|Oak::Web::TopLevel>

L<Oak::Web::Additional::Included|Oak::Web::Additional::Included>


=cut

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
