package Oak::Web::Additional::LabeledInput;

use strict;
use base qw(Oak::Web::HTML::Input);

sub show {
	my $self = shift;
	print "<LABEL FOR=\"".$self->get('name')."\">".$self->get('label')."</LABEL>";
	$self->SUPER::show;
}


1;

