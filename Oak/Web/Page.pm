package Oak::Web::Page;

use strict;
use Error qw(:try);
use base qw(Oak::Web::TopLevel);

=head1 NAME

Oak::Web::Page - Top level component of a web application

=head1 DESCRIPTION

This class is the web page itself.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Container|Oak::Web::Container>

L<Oak::Web::TopLevel|Oak::Web::TopLevel>

L<Oak::Web::Page|Oak::Web::Page>


=head1 PROPERTIES

The Oak::Web::Page object has the following properties:

=over

=item lang

Language of the HTML code

=item dir

Text direction (left to right or right to left

=item title

The title of this web page

=item meta

This property contains the text to include as meta information (as is, including the tag, but not < nor >)

=item linkrel

This property contains the text to include as linkrel (as is, including the tag, but not < nor >)

=item style

Space for stylesheet

=item expire_cookies

Boolean. If set will expire all the cookies of this session

=item script

Space for javascript

=back

=head1 METHODS

=over

=item show(%BAG)

This method is overrided to allow a Oak::Web::Page to optionally receive
a BAG that will be saved in the $self->{BAG} variable.

=back

=cut

sub show {
	my $self = shift;
	my %BAG = @_;
	$self->{BAG} = \%BAG;
	return $self->SUPER::show;
}

sub start_container {
	my $self = shift;
	my %cookies_params = $self->get_cookies_properties;
	if ($self->get('expire_cookies')) {
		$::SESSION->mark_all_cookies;
		$cookies_params{"-expires"} = "-1d";
	}
	my $ar_cookies = $::SESSION->get_cookies(%cookies_params);
	$ar_cookies ||= [];
	foreach my $c (@{$ar_cookies}) {
		print "Set-Cookie: $c\n";
	}
	print "Content-type: text/html\n\n";
	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"\n";
        print "  \"http://www.w3.org/TR/html4/strict.dtd\">\n";
	print "<HTML";
	if ($self->get('lang')) {
		print " lang=\"".$self->get('lang')."\"";
	}
	if ($self->get('dir')) {
		print " dir=\"".$self->get('dir')."\"";
	}
	print ">\n";
	print "<HEAD>\n";
	print "<TITLE>".$self->get('title')."</TITLE>\n";
	print "<".$self->get('meta').">\n" if $self->get('meta');
	print "<".$self->get('linkrel').">\n" if $self->get('linkrel');
	print "<STYLE>".$self->get('style')."</STYLE>\n" if $self->get('style');
	print "<SCRIPT><!--\n".$self->get('script')."\n--></SCRIPT>\n" if $self->get('script');
	print "</HEAD>\n";
}

sub end_container {
	print "</HTML>\n";
}

=over

=item get_cookies_properties

Return a HASH with the default properties of the cookies

=back

=cut

sub get_cookies_properties {
	()
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
