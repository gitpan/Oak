package Oak::Filer::XML;

use Error qw(:try);
use base qw(Oak::Filer);

=head1 NAME

Oak::Filer::XML - Saves/retrieves data to/from a XML file

=head1 DESCRIPTION

This module saves and retrieves properties using a XML file.
the file has the format:

  <!ELEMENT main (prop+)>
  <!ATTLIST prop
  name CDATA #REQUIRED
  value CDATA #REQUIRED>

An example of the XML file is:

  <main>
    <prop name="filename" value="/tmp/example123"/>
  </main>

=head1 HIERARCHY

  Oak::Object
  Oak::Filer
  Oak::Filer::XML

=head1 PROPERTIES

=over

=item TYPE

file or fh, defines if it will open a file or just use a
filehandle

=item FILENAME

if type equals file, then this file will be opened

=item FILEHANDLE

if type equals fh, then this fh will be used

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
	return $self->SUPER::constructor(%args);
}

=over 4

=item store(NAME=>VALUE)

Save the properties and the values

=back

=cut

sub store {
	my $self = shift;
	$self->load;
	my %parms = @_;
	foreach my $p (keys %params) {
		$self->{__CACHE__}{$p} = $params{$p};
	}
	require IO;
	require XML::Writer;
	my ($output, $writer);
	if ($self->get('type') eq "file") {
		$output = new IO::File(">".$self->get('FILENAME')) || throw Oak::Filer::XML::Error::ErrorWritingXML;
	} else {
		$output = $self->get("FILEHANDLE");
	}
	$writer = new XML::Writer(OUTPUT => $output) || throw Oak::Filer::XML::Error::ErrorWritingXML;
	$writer->startTag('main');
	for (keys %{$self->{__CACHE__}}) {
		$writer->startTag('prop', 'name' => $_, 'value' => $self->{__CACHE__}{$_});
		$writer->endTag('prop');
	}
	$writer->endTag('main');
	$writer->end();
	$output->close();
	return 1;
}

=over 4

=item load(NAME,NAME,...)

Loads the data and returns its value

=back

=cut

sub load {
	my $self = shift;
	my @properties = @_;
	require XML::Parser;
	unless ($self->{__CACHE__}) {
		my ($xml, $xml_hash);
		try {
			$xml = new XML::Parser(Style => 'Oak::Filer::XML::XMLHandlers');
			if ($self->get('type') eq "file") {
				$xml_hash = $xml->parsefile($self->get('FILENAME'));
			} else {
				$xml_hash = $xml->parse($self->get('FILEHANDLE'));
			}
		} except {
			throw Oak::Filer::Component::Error::ErrorReadingXML;
		};
		throw Oak::Filer::Component::Error::ErrorReadingXML unless ref $xml_hash eq "HASH";
		$self->{__CACHE__} = $xml_hash;
	}
	if (scalar @properties == 1) {
		return $self->{__CACHE__}{$properties[0]};
	} else {
		my @ret;
		foreach my $p (@properties) {
			push @ret, $self->{__CACHE__}{$p}
		}
		return @ret;
	}
}

# PACKAGE FOR XML READING
#################################################################
package Oak::Filer::XML::XMLHandlers;

sub Init {
	$Oak::Filer::XML::XMLHandlers::PROPS = {};
}

sub Start {
        my $p = shift;
        my $elem = shift;
        my %vars = @_;
        if ($elem eq "prop") {
		$Oak::Filer::XML::XMLHandlers::PROPS->{$vars{name}} = $vars{value}
        }
}


sub Final {
        return $Oak::Filer::XML::XMLHandlers::PROPS;
}


1;

__END__

=head1 EXAMPLES

  # To create the default filer
  require Oak::Filer::XML;
  my $filer = new Oak::Filer::XML(TYPE => 'file', FILENAME => 'config.xml');
  $filer->store(NAME=>VALUE);
  my %props = $filer->load(NAME);

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

