package Oak::DataModule;

use strict;
use base qw(Oak::Component);

=head1 NAME

Oak::DataModule - Container for non-visual components

=head1 DESCRIPTION

This component is the container for the non-visual components, like
a database connection.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::DataModule|Oak::DataModule>


=cut

1;

__END__

=head1 EXAMPLES

  my $datamodule = new Oak::DataModule(RESTORE_TOPLEVEL => "file.xml");

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
