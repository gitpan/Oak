package Oak::Filer::XML;

use Error qw(:try);
use base qw(Oak::Filer);

=head1 NAME

Oak::Filer::XML - Saves/retrieves data to/from a XML file

=head1 DESCRIPTION

This module saves and retrieves a structure from a XML file.

=head1 PROPERTIES

=over

=item TYPE

file or fh, defines if it will open a file or just use a
filehandle

=item FILENAME

if type equals file, then this file will be opened

=item FILEHANDLE

if type equals fh, then this fh will be used

=item HANDLER

Defines a package that contain the parse methods
defined by XML::Parser

=back

=head1 METHODS

=over 4

=item constructor

Overrided to receive the following parameters:

  FILENAME => filename of the XML file
  FH => filehandle of the XML file

You must pass one (and just one) of these parameters.
In the case you miss this will be throwed an
Oak::Error::ParamsMissing error.

There is another mandatory parameter, which is

  HANDLER => Your::Custom::XML::Handler

The class must follow the specification of XML::Parser,
if you dont understand what it means, please read its
documentation

=back

=cut

sub constructor {
	my $self = shift;
	my %args = @_;
	if ($args{FILENAME} && !$args{FH}) {
		$self->set
		  (
		   TYPE => "file",
		   FILENAME => $args{FILENAME}
		  );
	} elsif ($args{FH} && !$args{FILENAME}) {
		$self->set
		  (
		   TYPE => "fh",
		   FILEHANDLE => $args{FH}
		  );
	} else {
		throw Oak::Error::ParamsMissing;
	}
	if ($args{HANDLER}) {
		$self->set(HANDLER => $args{HANDLER});
	} else {
		throw Oak::Error::ParamsMissing;
	}
	return $self->SUPER::constructor(%args);
}

=over 4

=item store(NAME=>VALUE)

Saves the data into the XML file. Be carefull to set properties
only at the first level of the hash. If you have to set a property
that is in a deep level, please save the root of the hash.
This module do not create any cache. Every time you store a key of the
hash it will read the XML file.

=back

=cut

sub store {
	return 1;
}

=over 4

=item load(NAME,NAME,...)

Loads the data and returns its value (even if it is a reference).

=back

=cut

sub load {
	return 1;
}

=over 4

=item remove(NAME)

This function will delete this key from the hash and store.
As the store function, it will retrieve the hash from the
XML file again.

=back

=cut

sub remove {
	return 1;
}


1;

__END__

=head1 EXAMPLES

  # To create the default filer
  require Oak::Filer::XML;
  my $filer = new Oak::Filer::XML;
  $filer->store(NAME=>VALUE);
  my %props = $filer->load(NAME);

=head1 RESTRICTIONS

This is a skeleton class. It does not work. Actually I did not need it yet :)

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

