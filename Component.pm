package Oak::Component;
use base qw(Oak::Persistent);
use Carp;
use Error qw(:try);
use strict;

=head1 NAME

Oak::Component - Implements component capability in objects

=head1 DESCRIPTION

This module is the base for all objects that needs to
own other objects and other things.
Oak::Component objects will use a Oak::Component::Filer filer to store
the properties.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

=head1 PROPERTIES

=over

=item __XML_FILENAME__

The name of the xml file (needed if this is a top-level)

=item name

All components have a name property.

=back

=head1 EVENTS

=over

=item ev_onCreate

Called after the creation of the object

=back

=head1 METHODS

=over

=item constructor

This method is overrided from Oak::Object to create all the owned
components if it receives the RESTORE parameter with a hashref
of his and his owned components, or RESTORE_TOPLEVEL with the full
path of the XML file. Else does nothing. You
can (and you will want to) pass the OWNER special variable with
a reference to the object that you want to be the owner of this component.
If you override this method, you MUST call SUPER.

In the case of the name property is not passed in RESTORE, the constructor
will throw a Oak::Component::Error::MissingComponentName.

If this is a top-level component, you can pass the parameter DECLARE_GLOBAL
to create the $::TL::name reference... (This is used by Oak::Application)
you probably will not use it by yourself)

If you are designing this component you can use the IS_DESIGNING parameter
with a true value (this is used by Forest).

In the case of error in one of owned objects, the function will throw:
- Oak::Component::Error::MissingOwnedClassname if __CLASSNAME__ not found.
- Oak::Component::Error::MissingOwnedFile if require return a error.
- Oak::Component::Error::ErrorCreatingOwned if new return false.

=back

=cut

sub constructor {
	my $self = shift;
	my %parms = @_;
	if ($parms{IS_DESIGNING}) {
		$self->is_designing(1);
	}
	if ($parms{RESTORE_TOPLEVEL}) {
		# BUILD $parms{RESTORE} HASH.
		$self->feed("__XML_FILENAME__" => $parms{RESTORE_TOPLEVEL});
		$self->test_filer("COMPONENT");
		$parms{RESTORE} = $self->{__filers__}{"COMPONENT"}->load("mine");
		$parms{RESTORE}{__owned__} = $self->{__filers__}{"COMPONENT"}->load("owned");
		delete $parms{RESTORE_TOPLEVEL};
	}
	if (ref($parms{RESTORE}) eq 'HASH') {
		throw Oak::Component::Error::MissingComponentName unless $parms{RESTORE}{name};
		foreach my $p (keys %{$parms{RESTORE}}) {
			next if $p eq '__owned__';
			$self->feed($p => $parms{RESTORE}{$p});
		}
		if (ref($parms{RESTORE}{__owned__}) eq 'HASH') {
			foreach my $o (keys %{$parms{RESTORE}{__owned__}}) {
				# we know about the mandatory property __CLASSNAME__
				my $class = $parms{RESTORE}{__owned__}{$o}{__CLASSNAME__};
				throw Oak::Component::Error::MissingOwnedClassname unless $class;
				# We must load the module of the object
				my $result = eval "require $class";
				if (!$result || $@) {
					throw Oak::Component::Error::MissingOwnedFile;
				}
				my $obj = $class->new
				  (
				   RESTORE => $parms{RESTORE}{__owned__}{$o},
				   IS_DESIGNING => $parms{IS_DESIGNING},
				   OWNER => $self
				  );
				throw Oak::Component::Error::ErrorCreatingOwned unless $obj;
			}
		}
		$self->child_update;
	} else {
		$self->feed(%parms);
		throw Oak::Component::Error::MissingComponentName unless $self->get('name');
	}
	if (ref $parms{OWNER}) {
		$parms{OWNER}->register_child($self);
	}
	if ($parms{DECLARE_GLOBAL}) {
		eval '$::TL::'.$self->get('name').' = $self';
	}
	return $self->SUPER::constructor(%parms);
}

sub after_construction {
	my $self = shift;
	$self->SUPER::after_construction(@_);
	$self->dispatch('ev_onCreate');
}

=over

=item register_child(OBJECT, OBJECT)

Register object OBJECT in the owned tree with the name of the component as key.
Returns a Oak::Component::Error::AlreadyRegistered if a
object is already registered with this name.
The owned objects are stored on $self->{__owned__} hash.
And the owned properties are stored in the __owned__properties__
hash using the same key.

=back

=cut

sub register_child {
	my $self = shift;
	my @objs = @_;
	for my $p1 (@objs) {
		next unless ref $p1;
		if (exists $self->{__owned__}{$p1->get('name')}) {
			throw Oak::Component::Error::AlreadyRegistered;
		}
		$self->{__owned__}{$p1->get('name')} = $p1;
		# This code is dangerous...
		# But this is the most important
		# part.
		$self->{__owned__properties__}{$p1->get('name')} =
		  $p1->{__properties__};
		$p1->set_owner($self);
	}
	return 1;
}

=over

=item free_child(KEY)

Remove the object registered by the key KEY from the list of owned objects.
Actually, this function will delete the entry from the hash, and if this is
the last reference to that object, it will (obviously) destroy it.
Throws a Oak::Component::Error::NotRegistered if KEY not exists.

=back

=cut

sub free_child {
	my $self = shift;
	my $key = shift;
	unless (exists $self->{__owned__}{$key}) {
		throw Oak::Component::Error::NotRegistered;
	}
	delete $self->{__owned__}{$key};
	delete $self->{__owned__properties__}{$key};
	return 1;
}

=over

=item get_child(KEY)

Returns a reference to the owned object registered as KEY.
If KEY is not registered, throws a Oak::Component::Error::NotRegistered.

=back

=cut

sub get_child {
        my $self = shift;
	my $key = shift;
	unless (exists $self->{__owned__}{$key}) {
		throw Oak::Component::Error::NotRegistered;
	}
	return $self->{__owned__}{$key}
}

=over

=item list_childs

Returns an array with the key of the owned objects of this component

=back

=cut

sub list_childs {
	my $self = shift;
	my @array;
	return () unless ref $self->{__owned__};
	foreach my $k (keys %{$self->{__owned__}}) {
		push @array, $k;
	}
	return @array;
}

=over

=item set_owner(OBJ)

Defines the owner of this component. Creates a reference to
the owner of this object and stores in $self->{__owner__}
Throws a Oak::Component::Error::AlreadyOwned if a owner
is already defined.
Obs.: Do not set a object to be it's own owner, or you'll
create a circular reference.

=back

=cut

sub set_owner {
	my $self = shift;
	my $obj = shift;
	if (defined $self->{__owner__} && defined $obj) {
		throw Oak::Component::Error::AlreadyOwned;
	}
	$self->{__owner__} = $obj;
	return 1;
}

=over

=item change_name(NEWNAME)

Changes the name of this component. This function will try to
register this object again as another name and then free this
object as the other name.

=back

=cut

sub change_name {
	my $self = shift;
	my $newname = shift;
	if (ref $self->{__owner__}) {
		if ($self->{__owner__}->get_child($newname)) {
			throw Oak::Component::Error::AlreadyRegistered;
		}
		my $oldname = $self->get('name');
		$self->feed(name => $newname);
		my $owner_obj = $self->{__owner__};
		$owner_obj->free_child($oldname);
		$owner_obj->register_child($self);
	} else {
		$self->feed(name => $newname);
	}
	return 1;
}

=over

=item is_designing

If called without params then returns the actual value of
this special property, else sets the new value.
This function defines if the current object is being edited
to modify its behavior.

=back

=cut

sub is_designing {
	my $self = shift;
	my $set = shift;
	if (defined $set) {
		$self->{__is_designing__} = $set;
		return $set;
	} else {
		return $self->{__is_designing__};
	}
}

=over

=item store_all

This function will store (if this is a top-level component) all
his and his owned components properties on the filer. This function
is only called if the component is in "design time" (see is_designing)

=back

=cut

sub store_all {
	my $self = shift;
	$self->_test_filer_create_COMPONENT;
	return $self->{__filers__}{COMPONENT}->store
	  (
	   mine => $self->{__properties__},
	   owned => $self->{__owned__properties__}
	  );
}

=over

=item choose_filer

Overrided to choose the COMPONENT filer if this is a top-level component.

=back

=cut

sub choose_filer {
	my $self = shift;
	my $prop = shift;
	if (!defined $self->{__owner__} && $prop ne "__XML_FILENAME__" && $prop ne "__CLASSNAME__") {
		return 'COMPONENT';
	} else {
		return 'default';
	}
}

=over

=item test_filer

Overrided to create and test the COMPONENT filer when needed.
The COMPONENT filer needs the __XML_FILENAME__ property defined
to create using the correct file.

=back

=cut

sub test_filer {
	my $self = shift;
	my $filer = shift;
	for ($filer) {
		/^COMPONENT$/ && do { $self->_test_filer_create_COMPONENT ; last };
		$self->SUPER::test_filer($filer);
	}
	return 1;
}

# internal function
sub _test_filer_create_COMPONENT {
	my $self = shift;
	# WILL CREATE THE COMPONENT FILER
	require Oak::Filer::Component;
	$self->{__filers__}{COMPONENT} ||= new Oak::Filer::Component
	  (
	   FILENAME => $self->get("__XML_FILENAME__")
	  );
	return 1;
}

=over

=item child_update

Receives a change in one of the childs, abstract in Oak::Component.
Called everytime the "set" method is called in one of its owned
components.

=back

=cut

sub child_update {
	# Abstract function
}

=over

=item set

Overrided from Persistent to save the changes only when the
funcion store_all is called. In this case, it will only
feed the property with the value.

=back

=cut

sub set {
	my $self = shift;
	my %props = @_;
	for (keys %props) {
		/^name$/ && do { $self->change_name($props{$_}); next };
		$self->feed($_ => $props{$_});
	}
	if (defined $self->{__owner__}) {
		$self->{__owner__}->child_update;
	}
	return 1;
}

=over

=item dispatch(EVENT)

Dispatch the EVENT.

does nothing if the component is designing.

=back

=cut


sub dispatch {
	my $self = shift;
	return 1 if $self->is_designing;
	my $ev = shift;
	if ($self->get($ev)) {
		my $ev = $self->get($ev);
		my $result = eval $ev;
		if ($@) {
			if (my $err = Error::prior) {
				$err->throw
			} else {
				throw Error::Simple($@);
			}
		}
	}
	return 1;
}

=over

=item dispatch_all

This method will see if any event must be started by this component.
I.e.: if a submit button was clicked, test if there is an event for
this button and then launch the event.
This method must not be overrided. To dispatch an event, just set
$self->{__events__}{EVENTNAME} = 1, and this function will automatically
dispatch the event.

=back

=cut

sub dispatch_all {
	my $self = shift;
	$self->{__events__} ||= {};
	foreach my $ev (keys %{$self->{__events__}}) {
		$self->dispatch($ev);
	}
	return 1;
}




=over

=item AUTOLOAD

Oak::Component introduces AUTOLOAD to provide a quick acess
to the owned components. ie:

  $page->login->get('value');

Will be the same as:

  $page->get_child('login')->get('value');

=back

=cut

sub AUTOLOAD {
	my $self = shift;
	no strict 'vars';	# just for the line below;
	my $name = $AUTOLOAD;
	use strict 'vars';
	$name =~ s/.*://;
	my $obj;
	$obj = $self->get_child($name);
	return $obj;
}

=head1 EXCEPTIONS

The following exceptions are introduced by Oak::Component

=over

=item Oak::Component::Error::MissingOwnedClassname

This error is throwed when the property "__CLASSNAME__" is
not found in the property hash while doing "RECOVER", so its
impossible to create the object.

=back

=cut

package Oak::Component::Error::MissingOwnedClassname;
use base qw (Error);

sub stringify {
	return "Missing __CLASSNAME__ property while trying to create owned";
}

package Oak::Component::Error::MissingOwnedFile;
use base qw (Error);

=over

=item Oak::Component::Error::MissingOwnedFile

If perl could not require the module especified by the
__CLASSNAME__ property this exception is throwed.

=back

=cut

sub stringify {
	return "Error requiring module.";
}

package Oak::Component::Error::ErrorCreatingOwned;
use base qw (Error);

=over

=item Oak::Component::Error::ErrorCreatingOwned

If the new of the class returns false, this error is raised.

=back

=cut

sub stringify {
	return "Error creating object";
}

package Oak::Component::Error::AlreadyOwned;
use base qw (Error);

=over

=item Oak::Component::Error::AlreadyOwned

Trying to set the owner of a component that already has
an owner

=back

=cut

sub stringify {
	return "This object already has an owner";
}

package Oak::Component::Error::NotRegistered;
use base qw (Error);

=over

=item Oak::Component::Error::NotRegistered

Trying to reference an owned component that is not
registered

=back

=cut

sub stringify {
	return "This object is not registered";
}

package Oak::Component::Error::AlreadyRegistered;
use base qw (Error);

=over

=item Oak::Component::Error::AlreadyRegistered

Trying to register a component with a key that is
already used.

=back

=cut

sub stringify {
	return "This key has been already registered.";
}

package Oak::Component::Error::MissingComponentName;
use base qw (Error);

=over

=item Oak::Component::Error::MissingComponentName

Missing the name property

=back

=cut

sub stringify {
	return "The name property is mandatory.";
}


1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
