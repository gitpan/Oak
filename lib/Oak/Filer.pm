package Oak::Filer;

use strict;

use base qw(Oak::Object);

=head1 NAME

Oak::Filer - Saves Persistent Descendants properties

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Filer|Oak::Filer>


=head1 DESCRIPTION

This module implement the base for the modules which will save
data for Persistent Objects.

=head1 OBJECT METHODS

=over 4

=item store(NAME=>VALUE,NAME=>VALUE,...)

Abstract in Oak::Filer, stores the specified data.

=back

=cut

sub store {
	return 1;
}

=over 4

=item load(NAME,NAME,...)

Abstract in Oak::Filer, loads the specified data.

=back

=cut

sub load {
	return ();
}

1;

__END__

=head1 EXAMPLES

  # To create the default filer
  require Oak::Filer;
  my $filer = new Oak::Filer;
  $filer->store(NAME=>VALUE,NAME=>VALUE);
  my %props = $filer->load(NAME,NAME);

  -------------

  # to create a especialized filer
  use base qw(Oak::Filer);

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
