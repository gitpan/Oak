package Oak::Web::HTML::Radiogroup;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Radiogrroup - A virtual component to hold radio inputs

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Radiogroup|Oak::Web::HTML::Radiogroup>


=head1 PROPERTIES

name: The name of the radiogroup
value: The value of the radiogroup

=head1 EVENTS

ev_onChange: When the selected item was changed.

=cut

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	my $oldtext = $self->get('value');
	$self->set('value' => $cgi->param($self->get('name')));
	if ($oldtext ne $self->get('value')) {
		$self->{__events__}{ev_onChange} = 1;
	}
	return 1;
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
