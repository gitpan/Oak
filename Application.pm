package Oak::Application;

use strict;
use Error qw(:try);
use base qw(Oak::Object);

=head1 NAME

Oak::Application - Class for creating applications in Oak

=head1 HIERARCHY

  Oak::Object
  Oak::Application

=head1 DESCRIPTION

This is the class that will be used to create real applications,
the executable file will launch it.

When you create an application object, a reference is created as
$::APPLICATION. If you want to undef the Oak::Application object
by hand, you need to undef it also.

=head1 PROPERTIES

=over

=item topLevels

A hashref containing information about the toplevel objects:
  name => [class, xmlfile]

=item default

The default toplevel, the first toplevel to be shown on application
startup

=back

=head1 METHODS

=over

=item constructor

This method was overwrited to create all the objects passed to new.
The objects it creates will be available in the namespace ::TL. ie:
If one toplevel component have the name pagLogin, its object will
be available as $::TL::pagLogin.

=back

=cut

sub constructor {
	my $self = shift;
	my %parms = @_;
	$self->SUPER::constructor(%parms);
	$self->set('default' => $parms{default});
	delete $parms{default};
	$self->set('topLevels' => \%parms);
	$::APPLICATION = $self;
}

=over

=item initiateTopLevel(NAME)

Creates the Top-Level object NAME defined in the XMLFILE using CLASS.

The exceptions generated by Oak::Component wont be treated here, so,
they will propagate to the first level.

Exceptions generated by Oak::Application
  Oak::Application::Error::DuplicatedTopLevel - toplevel components have the same name
  Oak::Application::Error::ClassNotFound - toplevel class not found in lib

=back

=cut

sub initiateTopLevel {
	my $self = shift;
	my $name = shift;
	my $class = $self->get('topLevels')->{$name}[0];
	my $xmlfile = $self->get('topLevels')->{$name}[1];
	unless (eval "require $class") {
		throw Oak::Application::Error::ClassNotFound;
	}
	my $obj = $class->new(RESTORE_TOPLEVEL => $xmlfile);
	eval 'if (defined $::TL::'.$name.') { die } else { return 1 }' ||
	  throw Oak::Application::Error::DuplicatedTopLevel;
	eval '$::TL::'.$name.' = $obj';
	if ($self->get('default') eq $name) {
		eval '$::TL::default = $obj';
	}
	return 1;
}

=over

=item freeAllTopLevel

Destroy all the top level components.

=back

=cut

sub freeAllTopLevel {
	my $self = shift;
	my $name = shift;
	my $hr_topLevels = $self->get('topLevels');
	$hr_topLevels = {} unless ref $hr_topLevels;
	foreach my $name (keys %{$hr_topLevels}) {
		eval '$::TL::'.$name.' = undef';
	}
	$::TL::default = undef;
	return 1;
}

=over

=item DESTROY

Overwrited to undef the objects created in the ::TL namespace.

=back

=cut

sub DESTROY {
	my $self = shift;
	$self->freeAllTopLevel;
	return $self->SUPER::DESTROY;
}

=over

=item run

Abstract in Oak::Application, each type of application will
implement how they run.

=back

=cut

sub run {
	# Abstract in Oak::Application
	return 1
}

=head1 EXCEPTIONS

The following exceptions are introduced by Oak::Application

=over

=item Oak::Application::Error::ClassNotFound

This error is throwed when the class passed as parameter to
the new failed to be required.

=back

=cut

package Oak::Application::Error::ClassNotFound;
use base qw (Error);

sub stringify {
	return "Class not found in lib";
}

=over

=item Oak::Application::Error::DuplicatedTopLevel

This error is throwed when two toplevel components
have the same name

=back

=cut

package Oak::Application::Error::DuplicatedTopLevel;
use base qw (Error);

sub stringify {
	return "Two toplevels with the same name";
}


1;

__END__

=head1 EXAMPLES

  my $app = new Oak::Application
    (
     "formCreate" => ["MyApp::TopLevel1", "TopLevel1.xml"],
     "formList" => ["MyApp::TopLevel2", "TopLevel2.xml"],
     "formSearch" => ["MyApp::TopLevel3", "TopLevel3.xml"],
     "default" => "formCreate"
    );

  $app->run;			# abstract in Oak::Application

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
