package Oak::Web::HTML::Object;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Container);

=head1 NAME

Oak::Web::HTML::Object - OBJECT HTML tag (Container)

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::HTML::Object|Oak::Web::HTML::Object>


=head1 PROPERTIES

The Oak::Web::HTML::Object object has the properties defined by W3C

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes,
	 $self->events_attributes,
	 "declare",
	 "classid",
	 "codebase",
	 "data",
	 "type",
	 "codetype",
	 "archive",
	 "standby",
	 "height",
	 "width",
	 "usemap",
	 "name",
	 "tabindex"
  	);
}

sub start_container {
	my $self = shift;
	print "<OBJECT";
	print $self->print_html_attributes;
	print ">\n";
}

sub end_container {
	print "</OBJECT>\n";
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
