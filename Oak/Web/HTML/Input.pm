package Oak::Web::HTML::Input;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Input - An Input tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Input|Oak::Web::HTML::Input>


=head1 PROPERTIES

The Oak::Web::HTML::Input object has the properties defined by W3C:

If the input is of the radio type, another properties are used:
radiogroup: This property defines which radiogroup this radio belongs.
label: The text after the input

If the input is of the file type, another property is used:
filehandle: returns the filehandle to the uploaded file

=head1 EVENTS

ev_onChange: When the content of the input changes
ev_onClick: When this input was used to submit (if type eq button, submit, reset, image)
P.S.: When type eq image and the input was clicked, Oak automatically set x and y with the
data coming from cgi (server side image map)

=cut

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	my $oldtext = $self->get('value');
	if ($self->get('type') !~ /(button|submit|reset|image|radio|file|checkbox)/) {
		$self->set('value' => $cgi->param($self->get('name')));
		if ($oldtext ne $self->get('value')) {
			$self->{__events__}{ev_onChange} = 1;
		}
	} elsif ($self->get('type') =~ /file/) {
		$self->set('value' => $cgi->param($self->get('name')));
		if ($oldtext ne $self->get('value')) {
			$self->{__events__}{ev_onChange} = 1;
		}
		my $fh = $cgi->upload($self->get('name'));
		$self->set('filehandle' => $fh);
	} elsif ($self->get('type') =~ /image/) {
		if ($cgi->param($self->get('name').'.x')) {
			$self->{__events__}{ev_onClick} = 1;
			$self->set
			  (
			   "x" => $cgi->param($self->get('name').'.x'),
			   "y" => $cgi->param($self->get('name').'.y')
			  )
		}
	} elsif ($self->get('type') =~ /checkbox/) {
		if ($cgi->param($self->get('name'))) {
			$self->set("checked" => 1);
		}
	} else {
		if ($cgi->param($self->get('name'))) {
			$self->{__events__}{ev_onClick} = 1;
		}
	}
	return 1;
}

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "type",
	 "name",
	 "value",
	 "checked",
	 "disabled",
	 "readonly",
	 "size",
	 "maxlength",
	 "src",
	 "alt",
	 "usemap",
	 "ismap",
	 "tabindex",
	 "accesskey",
	 "onfocus",
	 "onblur",
	 "onselect",
	 "onchange",
	 "accept"
	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	my ($oldname, $my_value);
	$my_value = $self->get('value');
	if ($self->get('type') =~ /radio/) {
		$oldname = $self->get('name');
		$self->{__properties__}{name} = $self->get('radiogroup');
	}
	print "<INPUT";
	print $self->print_html_attributes;
	if ($self->get('type') =~ /radio/) {
		my $owner = $self->{__owner__};
		my $radiogroup = $owner->get_child($self->get('radiogroup'));
		my $selected = $radiogroup->get('value');
		if ($selected eq $my_value) {
			print " CHECKED";
		}
	}
	print ">";
	if ($self->get('type') =~ /radio/) {
		print " ".$self->get('label');
		$self->{__properties__}{name} = $oldname;
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
