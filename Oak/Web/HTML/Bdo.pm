package Oak::Web::HTML::Bdo;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Container);

=head1 NAME

Oak::Web::HTML::Bdo - Bdo HTML tag (Container)

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::HTML::Bdo|Oak::Web::HTML::Bdo>


=head1 PROPERTIES

The Oak::Web::HTML::Bdo object has the properties defined by W3C

=cut

sub valid_html_attributes {
	my $self = shift;
	(
	 $self->core_attributes,
	 $self->i18n_attributes
	);
}

sub start_container {
	my $self = shift;
	print "<BDO";
	print $self->print_html_attributes;
	print ">\n";
}

sub end_container {
	print "</BDO>\n";
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
