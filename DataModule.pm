package Oak::DataModule;

use strict;
use base qw(Oak::Component);

=head1 NAME

Oak::DataModule - Container for non-visual components

=head1 SYNOPSIS

  my $datamodule = new Oak::DataModule(RESTORE_TOPLEVEL => "file.xml");

=head1 DESCRIPTION

This component is the container for the non-visual components, like
a database connection.

=head1 METHODS

=over

=item constructor

This method is overwrited to implement the onCreate event.

=back

=cut

sub constructor {
	my $self = shift;
	my %parms = @_;
	$self->SUPER::constructor(%parms);
	if ($self->get('onCreate')) {
		my $str = $self->get('onCreate').'($self)';
		eval $str;
	}
	return 1;
}

=over

=item DESTROY

This method is overwrited to implement the onDestroy event.

=back

=cut

sub DESTROY {
	my $self = shift;
	$self->SUPER::DESTROY;
	if ($self->get('onDestroy')) {
		my $str = $self->get('onDestroy').'($self)';
		eval $str;
	}
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
