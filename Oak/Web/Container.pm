package Oak::Web::Container;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Visual - Superclass for all web containers

=head1 DESCRIPTION

This class implements the behavior of a container, which holds another
components inside it.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

=head1 PROPERTIES

=over

=item content

The content of the tag. Printed before the start_row.

=back

=head1 METHODS

=over

=item show

Overrided to call the show method of all the components it has inside it.

=back

=cut

sub show {
	my $self = shift;
	$self->SUPER::show;
	my $obj;
	if ($self->{__owner__}) {
		$obj = $self->{__owner__};
	} else {
		$obj = $self;
	}
	my @childs = $obj->list_childs;
	my @tobeshown;
	foreach my $k (@childs) {
		my $child = $obj->get_child($k);
		if ($child->get('parent') eq $self->get('name')) {
			push @tobeshown, $k;
		}
	}
	my $maxy = -1;
	my $maxx = -1;
	my @placement;
	foreach my $k (@tobeshown) {
		my $child = $obj->get_child($k);
		my $x = $child->get('left') || 0;
		my $y = $child->get('top') || 0;
		while (exists $placement[$y] and
		       exists $placement[$y][$x] and
		       defined $placement[$y][$x]) {
			$x++;
		}
		$maxy = $y if $y > $maxy;
		$maxx = $x if $x > $maxx;
		$placement[$y][$x] = $child;
	}
	$self->start_container;
	print $self->get('content');
	for (my $y = 0;$y <= $maxy; $y++) {
		$self->start_row;
		for (my $x = 0; $x <= $maxx; $x++) {
			$self->start_column;
			$placement[$y][$x]->show if
			  exists $placement[$y][$x] and
			    ref $placement[$y][$x];
			$self->end_column;
			$self->between_columns if $x <= $maxx - 1;
		}
		$self->end_row;
		$self->between_rows if $y <= $maxy - 1;
	}
	$self->end_container;
	return 1;
}

=over

=item start_container

Show the html before the first row

=back

=cut

sub start_container {
	return;
}

=over

=item start_row

Show the html before the first column in one row

=back

=cut

sub start_row {
	return;
}

=over

=item start_column

Show the html before the component in this row

=back

=cut

sub start_column {
	return;
}

=over

=item end_column

Show the html after the component in this row

=back

=cut

sub end_column {
	print " ";
}

=over

=item between_columns

Show the html between columns

=back

=cut

sub between_columns {
	print " ";
}

=over

=item end_row

Show the html after the last column in one row

=back

=cut

sub end_row {
	return;
}

=over

=item between_rows

Show the html between rows

=back

=cut

sub between_rows {
	print " ";
}

=over

=item end_container

Show the html after the last row

=back

=cut

sub end_container {
	return;
}

1;

__END__

=head1 EXAMPLES

  use base qw(Oak::Web::Container);

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
