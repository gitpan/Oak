package Oak::Web::Additional::Template;

use strict;
use Error qw(:try);
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::Additional::Template - Component for adding free text

=head1 DESCRIPTION

This module will be used to insert free text inside your web page.
It will substitute text enclosed by <% and %> with the key setted
in the __VARS__ property.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::Template|Oak::Web::Additional::Template>


=head1 PROPERTIES

=over

=item type

file or string. If type eq file, it will try to open the source and use it.
Else it will print the source.

=item source

This property indicates where is the source file to be printed or if the type is
string, the code itself.

=item __VARS__

There is a shortcut method to set this, set_vars. This property contains a
hashref to the list of variables to be substituted.

=back

=cut

sub show {
	my $self = shift;
	$self->SUPER::show;
	if ($self->get('type') eq "file") {
		unless (open (TEMPLATE, $self->get('source'))) {
			throw Oak::Web::Additional::Template::Error::FileNotFound;
		}
		while (<TEMPLATE>) {
			s/\<\%\s*($1)\s*\%\>/$self->{__VARS__}{$1}/ge;
			print;
		}
	} else {
		my $string = $self->get('source');
		$string =~ s/\<\%\s*($1)\s*\%\>/$self->{__VARS__}{$1}/gse;
		print $string;
	}
}

=head1 METHODS

=over

=item set_vars(HASH)

Define the variables that will be used for substitution in the template.

=back

=cut

sub set_vars {
	my $self = shift;
	my %vars = @_;
	$self->{__VARS__} = \%vars;
}

=head1 EXCEPTIONS

The following exceptions are introduced by Oak::Web::Additional::Template

=over

=item Oak::Web::Additional::Template::Error::FileNotFound

When source file is not found this error is thrown

=back

=cut

package Oak::Web::Additional::Template::Error::FileNotFound;
use base qw (Error);

sub stringify {
	return "File not found when trying to open it";
}


1;

__END__

=head1 EXAMPLES

  text.htm
  -----------
  Hi <%fullName%>,
  
  It is a pleasure to meet you.
  
  
  Cheers
  -----------
  
  The method set_vars will receive a hash with the variables to
  be substituted.
  When you want to substitute some variable put its name between <% and %>

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
