package Oak::Filer::Component;

use base qw(Oak::Filer);
use Error qw(:try);
use strict;

=head1 NAME

Oak::Filer::Component - Filer to save/load data into/from Components

=head1 DESCRIPTION

This module provides access for saving and reading data into a Component XML, to be used by
components. Must pass XML FILENAME

=head1 HIERARCHY

  Oak::Object
  Oak::Filer
  Oak::Filer::Component

=head1 PROPERTIES

=over

=item FILENAME

The name of the XML file. Defined by constructor

=back

=head1 METHODS

=over

=item constructor

Overwrited to test the existance of XML file.

=back

=cut


sub constructor{
	my $self = shift;
	my %parms = @_;
	throw Oak::Filer::Component::Error::XMLInexistent unless -f $parms{FILENAME};
	$self->set('FILENAME' => $parms{FILENAME});
	return $self->SUPER::constructor(%parms);
}


=over

=item load

Load the information from the XML file and return one of the following properties
  "mine" => the properties of the owner of this XML
  "owned" => a hash with all the owned components and their properties

Throws a Oak::Filer::Component::Error::ErrorReadingXML when there was something wrong
when trying to read the XML file.

=back

=cut

sub load {
	my $self = shift;
	my $what = shift;
	require XML::Parser;
	my ($xml, $xml_hash);
	try {
		$xml = new XML::Parser(Style => 'Oak::Filer::Component::XMLHandlers');
		$xml_hash = $xml->parsefile($self->get('FILENAME'));
	} except {
		throw Oak::Filer::Component::Error::ErrorReadingXML;
	};
	throw Oak::Filer::Component::Error::ErrorReadingXML unless ref $xml_hash eq "HASH";
	$self->{__MINE__} = $xml_hash->{mine};
	$self->{__OWNED__} = $xml_hash->{owned};
	return $self->{__MINE__} if $what eq 'mine';
	return $self->{__OWNED__} if $what eq 'owned';
}

=over

=item store

Store the information into the XML file. You can pass any of these parameters,
but you have to pass ALL the parameters, because the hash you pass as a parameter
will overwrite the old hash.
  "mine" => the properties of the owner of this XML
  "owned" => a hash with all the owned components and their properties

Throws a Oak::Filer::Component::Error::ErrorReadingXML when there was something wrong
when trying to read the XML file.

=back

=cut

sub store {
	my $self = shift;
	my %parms = @_;
	$self->{__MINE__} = $parms{mine} if ref $parms{mine} eq "HASH";
	$self->{__OWNED__} = $parms{owned} if ref $parms{owned} eq "HASH";
	require IO;
	require XML::Writer;
	my ($output, $writer);
	$output = new IO::File(">".$self->get('FILENAME')) || throw Oak::Filer::Component::Error::ErrorWritingXML;
	$writer = new XML::Writer(OUTPUT => $output) || throw Oak::Filer::Component::Error::ErrorWritingXML;
	$writer->startTag('main');
	for (keys %{$self->{__MINE__}}) {
		$writer->startTag('prop', 'name' => $_, 'value' => $self->{__MINE__}{$_});
		$writer->endTag('prop');
	}
	for my $element (keys %{$self->{__OWNED__}}) {
		$writer->startTag('owned', 'name' => $element);
		for (keys %{$self->{__OWNED__}{$element}}) {
			$writer->startTag('prop', 'name' => $_, 'value' => $self->{__OWNED__}{$element}{$_});
			$writer->endTag('prop');
		}
		$writer->endTag('owned');
	}	
	$writer->endTag('main');
	$writer->end();
	$output->close();
	return 1;

}

# PACKAGE FOR XML READING
#################################################################
package Oak::Filer::Component::XMLHandlers;

sub Init {
	$Oak::Filer::Component::XMLHandlers::OWNEDNAME = '';
	%Oak::Filer::Component::XMLHandlers::OWNED = ();
	%Oak::Filer::Component::XMLHandlers::MINE = ();
}

sub Start {
        my $p = shift;
        my $elem = shift;
        my %vars = @_;
        if ($elem eq "prop") {
		if ($Oak::Filer::Component::XMLHandlers::OWNEDNAME) {
			$Oak::Filer::Component::XMLHandlers::OWNED{$Oak::Filer::Component::XMLHandlers::OWNEDNAME}{$vars{name}} = $vars{value};
		} else {
			$Oak::Filer::Component::XMLHandlers::MINE{$vars{name}} = $vars{value}
		}
        } elsif ($elem eq "owned") {
                $Oak::Filer::Component::XMLHandlers::OWNEDNAME = $vars{name};
		$Oak::Filer::Component::XMLHandlers::OWNED{$vars{name}}{name} = $vars{name};
	}
}

sub End {
        my $p = shift;
        my $elem = shift;
        if ($elem eq "owned") {
                $Oak::Filer::Component::XMLHandlers::OWNEDNAME = ''
        }
}

sub Final {
        return {
		mine => \%Oak::Filer::Component::XMLHandlers::MINE,
		owned => \%Oak::Filer::Component::XMLHandlers::OWNED
	       };
}



=head1 EXCEPTIONS

The following exceptions are introduced by Oak::Filer::Component

=over

=item Oak::Filer::Component::Error::XMLInexistent

This error is throwed when the XML FILE does not exist.

=back

=cut

package Oak::Filer::Component::Error::XMLInexistent;
use base qw (Error);

sub stringify {
	return "Missing XML File";
}

=over

=item Oak::Filer::Component::Error::ErrorReadingXML

This error is throwed when there is some problem with the XML while trying to read it.

=back

=cut

package Oak::Filer::Component::Error::ErrorReadingXML;
use base qw (Error);

sub stringify {
	return "There was something wrong when trying to read the XML file";
}

=over

=item Oak::Filer::Component::Error::ErrorWritingXML

This error is throwed when there is some problem with the XML while trying to read it.

=back

=cut

package Oak::Filer::Component::Error::ErrorWritingXML;
use base qw (Error);

sub stringify {
	return "There was something wrong when trying to write the XML file";
}

1;

__END__

=head1 EXAMPLES

  require Oak::Filer::Component;

  my $filer = new Oak::Filer::Component(
					FILENAME => "tralala.xml"
				       )

  my $hr_props = $filer->load("mine");
  my $hr_owned = $filer->load("owned");
  $filer->store(
		mine => $hr_props,
		owned => $hr_owned
	       );


=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


