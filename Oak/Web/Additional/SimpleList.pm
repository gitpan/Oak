package Oak::Web::Additional::SimpleList;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::Additional::SimpleList - Component to create a simple indented list

=head1 DESCRIPTION

This components outputs an indented list.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::SimpleList|Oak::Web::Additional::SimpleList>


=head1 PROPERTIES

=over

=item list

A string with the list of items. Each item in one line. The indentation is
made by the number of white spaces before the first character.

=back

=cut

sub show {
	my $self = shift;
	$self->SUPER::show;
	my @lines = split(/\n/, $self->get('list'));
	my $lastlevel = 0;
	print "<UL>\n";
	foreach my $item (@lines) {
		my $level = 0;
		while ($item =~ s/^\s//) {
			$level++;
		}
		while ($level > $lastlevel) {
			print "<UL>\n";
			$lastlevel++;
		}
		while ($level < $lastlevel) {
			print "</UL>\n";
			$lastlevel--;
		}
		print "<LI>".$self->format_item($item)."\n";
	}
	while ($lastlevel >= 0) {
		print "</UL>\n";
		$lastlevel--;
	}
}

=head1 METHODS

=over

=item format_item($item)

Receives the text without the indentation and return it in the
required format. In SimpleList, it does nothing. But you can
implement some nice features, like a link.

=back

=cut

sub format_item {
	my $self = shift;
	my $item = shift;
	return $item;
}

1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
