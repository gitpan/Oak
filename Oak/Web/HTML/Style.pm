package Oak::Web::HTML::Style;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::HTML::Style - STYLE HTML tag (Visual)

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::HTML::Style|Oak::Web::HTML::Style>


=head1 PROPERTIES

=over

=item css

The Cascading Style Sheet text

=back

The Oak::Web::HTML::Style object has the properties defined by W3C

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->i18n_attributes,
	 "type",
	 "media",
	 "title"
  	);
}

sub show {
	my $self = shift;
	$self->SUPER::show;
	print "<STYLE";
	print $self->print_html_attributes;
	print ">".$self->get('css')."</STYLE>\n";
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
