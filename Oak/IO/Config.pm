package Oak::IO::Config;

use strict;
use base qw(Oak::Component);

=head1 NAME

Oak::IO::Config - Component for handling configuration files

=head1 DESCRIPTION

This object will manage the configuration file for your application

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::IO::Config|Oak::IO::Config>


=head1 PROPERTIES

=over

=item filename

The full path of the filename for this config file

=back

=head1 METHODS

=cut

sub constructor {
	my $self = shift;
	my %params = shift;
	$self->SUPER::constructor(%params);
	unless (ref $params{RESTORE}) {
		$self->set('filename') = $params{RESTORE}{filename};
	}
	unless ($self->get('filename')) {
		throw Oak::Error::ParamsMissing;
	}
	require Oak::Filer::XML;
	$self->{__XML_FILER__} = new Oak::Filer::XML
	  (
	   FILENAME => $self->get('filename')
	  );
}

=over

=item param(NAME) or param(NAME,VALUE)

Load or set the value of a configuration parameter.

=back

=cut

sub param {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	if ($value) {
		return $self->{__XML_FILER__}->store($name => $value);
	} else {
		return $self->{__XML_FILER__}->load($name);
	}
}

1;

__END__


=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

