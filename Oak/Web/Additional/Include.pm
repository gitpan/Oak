package Oak::Web::Additional::Include;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::Include - Includes another toplevel inside

=head1 DESCRIPTION

This component allows you to include another toplevel
component inside a container (i.e.: a Oak::Web::Page).
But the included component is created and destroyed in
the show method. If this toplevel has any action, it must
be declared at the creation of the Oak::Web::Application.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::Include|Oak::Web::Additional::Include>


=head1 PROPERTIES

The Oak::Web::Additional::Include has the following properties

=over

=item xml_filename

Where is the xml file of the included toplevel.

=item classname

The classname of the component

=back

=cut

sub show {
	my $self = shift;
	$self->SUPER::show;
	my $comp = $self->get('classname')->new
	  (
	   RESTORE_TOPLEVEL => $self->get('xml_filename')
	  );
	$comp->show;
}

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
