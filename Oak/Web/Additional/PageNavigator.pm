package Oak::Web::Additional::PageNavigator;

use strict;
use base qw(Oak::Web::Visual);

=head1 NAME

Oak::Web::Additional::PageNavigator - A navigator for paged data (like goooooooogle)

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::Web::Visual|Oak::Web::Visual>

L<Oak::Web::Additional::PageNavigator|Oak::Web::Additional::PageNavigator>

=head1 DESCRIPTION

Creates a navigation panel with links to help in the control of paged information, like
reports or any other search feature.

This component will do exactly the same job that the Goooooooogle links does.

The HTML representation of this component is a DIV with a lot of A inside.

=head1 PROPERTIES

=over

=item form_name

The name of the form component that this navigator is inside.

=item current_page

The current page. When the users click on a link this attribute is updated.

=item total_pages

Used to control the links and when to hide the "next" ( << ) link.
If you do not define this property, the navigator will not be shown.

=item class

The class for the DIV element

=item class_previous

The class for the "previous" link ( << )

=item class_page_link

The class for the link on the page numbers

=item class_this_page

The class for the number of the current page (the current page does not have a link)

=item class_next

The class for the "next" link ( >> )

=back

=head1 EVENTS

=over

=item ev_onClick

when one of the links is clicked.

=back

=cut

sub show {
	my $self = shift;
	return undef unless $self->get("total_pages");
	print "<DIV";
	if ($self->get('class')) {
		print " CLASS='".$self->get('class')."'";
	}
	print ">";
	print "<INPUT TYPE='hidden' NAME='".$self->get('name')."___page___' VALUE='".$self->get('current_page')."'>";
	print "<INPUT TYPE='hidden' NAME='".$self->get('name')."___clicked___' VALUE='0'>";
	if ($self->get('current_page') > 1) {
		print $self->_get_link($self->get('current_page')-1,$self->get('class_previous'))."\&lt;\&lt;</A>";
	}
	for (my $i=1;$i <= $self->get('total_pages');$i++) {
		print ' ';
		if ($i == $self->get('current_page')) {
			print "<SPAN CLASS=\"".$self->get('class_this_page')."\">".$i."</SPAN>";
		} else {
			print $self->_get_link($i,$self->get('class_page_link')).$i."</A>";
		}
	}
	if ($self->get('current_page') < $self->get('total_pages')) {
		print ' '.$self->_get_link($self->get('current_page')+1,$self->get('class_next'))."\&gt;\&gt;</A>";
	}
	print "</DIV>";
}

sub _get_link {
	my $self = shift;
	my $num = shift;
	my $class = shift;
	return "<A CLASS=\"".$class."\" HREF=\"javascript:document.".$self->get('form_name').".".$self->get('name')."___page___.value=".$num.";document.".$self->get('form_name').".".$self->get('name')."___clicked___.value=1;document.".$self->get('form_name').".submit()\">";
}

sub receive_cgi {
	my $self = shift;
	my $cgi = shift;
	$self->set(current_page => $cgi->param($self->get('name')."___page___"));
	if ($cgi->param($self->get('name')."___clicked___")) {
		$self->{__events__}{ev_onClick} = 1;
	}
}

1;
