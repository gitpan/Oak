package Oak::Web::HTML::Legend;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Legend - A Legend tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Legend|Oak::Web::HTML::Legend>


=head1 PROPERTIES

Caption: The text of the legend

The Oak::Web::HTML::Legend object has the  properties defined by W3C.

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "accesskey"
	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<LEGEND";
	print $self->print_html_attributes;
	print ">".$self->get('caption')."</LEGEND>\n";
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
