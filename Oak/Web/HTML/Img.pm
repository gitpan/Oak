package Oak::Web::HTML::Img;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Img - IMG HTML tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Img|Oak::Web::HTML::Img>


=head1 PROPERTIES

The Oak::Web::HTML::IMG object has the properties defined by W3C

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "src",
	 "alt",
	 "longdesc",
	 "name",
	 "height",
	 "width",
	 "usemap",
	 "ismap",
	 "border"
  	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<IMG";
	print $self->print_html_attributes;
	print ">\n";
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
