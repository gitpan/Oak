package Oak::Web::Additional::DateTimeField;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);
use Time::Local;

=head1 NAME

Oak::Web::Additional::DateTimefield - Component to create a date/time field

=head1 DESCRIPTION

This component creates a date field with 6 different inputs. The inputs
can be show in the order you config and with the separator you choose.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::Datefield|Oak::Web::Additional::Datefield>


=head1 PROPERTIES

=over

=item show_seconds

Defaults to false.

=item format

YMDhms,DMYhms or MDYhms. The format that the inputs will be shown. Defaults to DMYhms.

=item datetime

The datetime itself. It _is_ in the unix timestamp format. And _only_ this format.

=item date_separator

The character that separates the date inputs, defaults to "/"

=item time_separator

The character that separates the time inputs, defaults to ":"

=item required

If true, then the field must be filled, else not.

=back

=cut

sub constructor {
	my $self = shift;
	my %params = @_;
	if (ref $params{RESTORE} eq "HASH") {
		$params{RESTORE}{format} ||= "DMYhms";
		$params{RESTORE}{date_separator} ||= "/";
		$params{RESTORE}{time_separator} ||= ":";
	}
	$self->SUPER::constructor(%params);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	my ($y, $m, $d, $ho, $mi, $se) = $self->_createSubInputs;
	if ($self->get('format') =~ /^YMD/) {
		$y->show;
		print $self->get('date_separator');
		$m->show;
		print $self->get('date_separator');
		$d->show;
	} elsif ($self->get('format') =~ /^MDY/) {
		$m->show;
		print $self->get('date_separator');
		$d->show;
		print $self->get('date_separator');
		$y->show;
	} else {
		$d->show;
		print $self->get('date_separator');
		$m->show;
		print $self->get('date_separator');
		$y->show;
	}
	print '&nbsp;';
	$ho->show;
	print $self->get('time_separator');
	$mi->show;
	if ($self->get('show_seconds')) {
		print $self->get('time_separator');
		$se->show;
	}
	$self->free_child($self->get('name')."____year____");
	$self->free_child($self->get('name')."____month____");
	$self->free_child($self->get('name')."____day____");
	$self->free_child($self->get('name')."____hour____");
	$self->free_child($self->get('name')."____mins____");
	$self->free_child($self->get('name')."____secs____");
}

sub check_syntax {
	my $self = shift;
	if (!$self->get('datetime') && $self->get('required')) {
		$self->mark_error;
		throw Oak::Error::ParamsMissing;
	} elsif (!$self->get('datetime') && !$self->get('required')) {
		return 1;
	} elsif ($self->get('datetime') eq "ERROR") {
		$self->mark_error;
		throw Oak::Web::Additional::Datefield::Error::InvalidDate;
	}
}

sub _createSubInputs {
	my $self = shift;
	require Oak::Web::HTML::Input;
	my $time = $self->get('datetime');
	$time = 0 if $time eq "ERROR";
	my ($se,$mi,$ho,$d,$m,$y);
	unless ($time == 0) {
		($se,$mi,$ho,$d,$m,$y) = localtime($self->get('datetime'));
		$m++;
		$y+=1900;
	}
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
	my $hoinput = new Oak::Web::HTML::Input
	  (
	   OWNER => $self,
	   RESTORE =>
	   {
	    type => "text",
	    value => $ho,
	    name => $self->get('name')."____hour____",
	    size => 2,
	    maxlenght => 2,
	    class => $class
	   }
	  );
	my $miinput = new Oak::Web::HTML::Input
	  (
	   OWNER => $self,
	   RESTORE =>
	   {
	    type => "text",
	    value => $mi,
	    name => $self->get('name')."____mins____",
	    size => 2,
	    maxlenght => 2,
	    class => $class
	   }
	  );
	my $seinput = new Oak::Web::HTML::Input
	  (
	   OWNER => $self,
	   RESTORE =>
	   {
	    type => "text",
	    value => $se,
	    name => $self->get('name')."____secs____",
	    size => 2,
	    maxlenght => 2,
	    class => $class
	   }
	  );
	return ($yinput, $minput, $dinput, $hoinput, $miinput, $seinput)
}

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	my $oldValue = $self->get('date');
	my ($y, $m, $d, $ho, $mi, $se) = $self->_createSubInputs;
	$y->receive_cgi($cgi);
	$m->receive_cgi($cgi);
	$d->receive_cgi($cgi);
	$ho->receive_cgi($cgi);
	$mi->receive_cgi($cgi);
	$se->receive_cgi($cgi);
	my $time;
	my ($vy, $vm, $vd, $vho, $vmi, $vse);
	$vse = $se->get('value') || 0;
	$vmi = $mi->get('value') || 0;
	$vho = $ho->get('value') || 0;
	$vd = $d->get('value') || 0;
	$vm = $m->get('value') || 0;
	$vy = $y->get('value') || 0;
	if (!$vse && !$vmi && !$vho && !$vd && !$vm && !$vy) {
		$time = 0;
	} else {
		eval {
			$time = Time::Local::timelocal
			  (
			   $vse,
			   $vmi,
			   $vho,
			   $vd,
			   $vm-1,
			   $vy-1900
			  );
		};
		if ($@) {
			$self->mark_error;
			$self->set(datetime => "ERROR");
		}
	}
	$self->set(datetime => $time);
	if ($self->get('date') eq "--") {
		$self->set('date' => "");
	}
	if ($oldValue ne $self->get('date')) {
		$self->{__events__}{ev_onChange} = 1;
	}
	$self->free_child($self->get('name')."____year____");
	$self->free_child($self->get('name')."____month____");
	$self->free_child($self->get('name')."____day____");
	$self->free_child($self->get('name')."____hour____");
	$self->free_child($self->get('name')."____mins____");
	$self->free_child($self->get('name')."____secs____");
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
