package Oak::Web::Additional::Datefield;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::Additional::Datefield - Component to create a date field

=head1 DESCRIPTION

This component creates a date field with 3 different inputs. The inputs
can be show in the order you config and with the separator you choose.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::Datefield|Oak::Web::Additional::Datefield>


=head1 PROPERTIES

=over

=item format

YMD,DMY or MDY. The format that the inputs will be shown. Defaults to DMY.

=item date

The date itself. It _is_ in the forat YYYY-MM-DD. And _only_ this format.

=item separator

The character that separates the inputs, defaults to "/"

=item required

If true, then the field must be filled, else not.

=back

=cut

sub constructor {
	my $self = shift;
	my %params = @_;
	if (ref $params{RESTORE} eq "HASH") {
		$params{RESTORE}{format} ||= "DMY";
		$params{RESTORE}{separator} ||= "/";
	}
	$self->SUPER::constructor(%params);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	my ($y, $m, $d) = $self->_createSubInputs;
	if ($self->get('format') eq "YMD") {
		$y->show;
		print $self->get('separator');
		$m->show;
		print $self->get('separator');
		$d->show;
	} elsif ($self->get('format') eq 'MDY') {
		$m->show;
		print $self->get('separator');
		$d->show;
		print $self->get('separator');
		$y->show;
	} else {
		$d->show;
		print $self->get('separator');
		$m->show;
		print $self->get('separator');
		$y->show;
	}
	$self->free_child($self->get('name')."____year____");
	$self->free_child($self->get('name')."____month____");
	$self->free_child($self->get('name')."____day____");
}

sub check_syntax {
	my $self = shift;
	if (!$self->get('date') && $self->get('required')) {
		throw Oak::Error::ParamsMissing;
	} elsif (!$self->get('date') && !$self->get('required')) {
		return 1;
	} else {
		require Time::Local;
		my ($y,$m,$d) = split(/-/, $self->get('date'));
		eval {
			my $time = Time::Local::timelocal
			  (
			   0,0,0,
			   $d,
			   $m-1,
			   $y-1900
			  );
		} or do {
			$self->mark_error;
			throw Oak::Web::Additional::Datefield::Error::InvalidDate;
		};
		return 1;
	}
}

sub _createSubInputs {
	my $self = shift;
	require Oak::Web::HTML::Input;
	my ($y, $m, $d) = split(/-/, $self->get('date'));
	my $class = $self->get('class');
	my $yinput = new Oak::Web::HTML::Input
	  (
	   OWNER => $self,
	   RESTORE =>
	   {
	    type => "text",
	    value => $y,
	    name => $self->get('name')."____year____",
	    size => 4,
	    maxlenght => 4,
	    class => $class
	   }
	  );
	my $minput = new Oak::Web::HTML::Input
	  (
	   OWNER => $self,
	   RESTORE =>
	   {
	    type => "text",
	    value => $m,
	    name => $self->get('name')."____month____",
	    size => 2,
	    maxlenght => 2,
	    class => $class
	   }
	  );
	my $dinput = new Oak::Web::HTML::Input
	  (
	   OWNER => $self,
	   RESTORE =>
	   {
	    type => "text",
	    value => $d,
	    name => $self->get('name')."____day____",
	    size => 2,
	    maxlenght => 2,
	    class => $class
	   }
	  );
	return ($yinput, $minput, $dinput)
}

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	my $oldValue = $self->get('date');
	my ($y, $m, $d) = $self->_createSubInputs;
	$y->receive_cgi($cgi);
	$m->receive_cgi($cgi);
	$d->receive_cgi($cgi);
	$self->set(date => $y->get('value')."-".$m->get('value')."-".$d->get('value'));
	if ($self->get('date') eq "--") {
		$self->set('date' => "");
	}
	if ($oldValue ne $self->get('date')) {
		$self->{__events__}{ev_onChange} = 1;
	}
	$self->free_child($self->get('name')."____year____");
	$self->free_child($self->get('name')."____month____");
	$self->free_child($self->get('name')."____day____");
}

=head1 EXCEPTIONS

=over

=item Oak::Web::Additional::Datefield::Error::InvalidDate

An invalid date was found.

=back

=cut

package Oak::Web::Additional::Datefield::Error::InvalidDate;

use base qw (Error);

sub stringify {
	return "Invalid Date";
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
