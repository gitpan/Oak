package Oak::Web::HTML::Param;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Param - Param HTML tag

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Param|Oak::Web::HTML::Param>


=head1 PROPERTIES

The Oak::Web::HTML::Param object has the properties defined by W3C

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 "id",
	 "name",
	 "value",
	 "valuetype",
	 "type"
  	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<PARAM";
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
