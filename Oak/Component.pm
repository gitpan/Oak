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

A Component can be created in the following ways:

  # 1 - Instanciating a top level
  my $comp = new MyComponent(RESTORE_TOPLEVEL => "FILENAME_OR_FILEHANDLE");

  # 2 - Instanciating a normal component
  my $comp = new MyComponent(RESTORE => { this => "that", name => "bla" });

The following options are accepted in the constructor:

=over

=item IS_DESIGNING

if true, this component will not dispatch any event. Not even ev_onCreate.

=item OWNER

The owner component of this component.

=item DECLARE_GLOBAL

A variable $::TL::component_name will be created in reference to this object.
If you set this option, remember to undef this variable later.

=back

This function throws the following errors:

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
		delete $parms{IS_DESIGNING};
	}
	my $owner = undef;
	if (ref $parms{OWNER}) {
		$owner = $parms{OWNER};
		delete $parms{OWNER};
	}
	my $declare_global = 0;
	if ($parms{DECLARE_GLOBAL}) {
		$declare_global = 1;
		delete $parms{DECLARE_GLOBAL};
	}
	if ($parms{RESTORE_TOPLEVEL}) {
		$self->restore_toplevel($parms{RESTORE_TOPLEVEL});
	} elsif (ref($parms{RESTORE}) eq 'HASH') {
		$self->restore($parms{RESTORE});
	} else {
		warn "Deprecated behavior called by ".(caller(2))[1]."(".(caller(2))[2]."), Component properties must be passed into the RESTORE hash. This behavior will be disabled in the future\n";
		$self->restore(\%parms);
	}
	if ($owner) {
		$owner->register_child($self);
	}
	if ($declare_global) {
		eval '$::TL::'.$self->get('name').' = $self';
	}
	return $self->SUPER::constructor(%parms);
}

=over

=item restore_toplevel($xml_filename)

This function is called when the constructor receives the RESTORE_TOPLEVEL param.
It loads the toplevel data from the $xml_filename file, calls restore for this
object and create all the owned components.

=back

=cut

sub restore_toplevel {
	my $self = shift;
	my $xml_filename = shift;
	$self->feed("__XML_FILENAME__" => $xml_filename);
	$self->test_filer("COMPONENT");
	my $xml_hash = $self->{__filers__}{"COMPONENT"}->load;
	$self->restore($xml_hash->{mine});
	foreach my $o (keys %{$xml_hash->{owned}}) {
		$self->create_owned($xml_hash->{owned}{$o});
	}
}

=over

=item restore($data)

Receives a hash ref with the properties to be restored.

=back

=cut

sub restore {
	my $self = shift;
	my $data = shift;
	throw Oak::Component::Error::MissingComponentName -text => ref $self unless $data->{name};
	$self->feed(%{$data});
}

=over

=item create_owned($data)

Creates the owned component specified into the hashref $data.

=back

=cut

sub create_owned {
	my $self = shift;
	my $data = shift;
	# we know about the mandatory property __CLASSNAME__
	my $class = $data->{__CLASSNAME__};
	throw Oak::Component::Error::MissingOwnedClassname -text => $data->{name} unless $class;
	# We must load the module of the object
	my $result = eval "require $class";
	if (!$result || $@) {
		throw Oak::Component::Error::MissingOwnedFile -text => $data->{name};
	}
	$class->new
	  (
	   RESTORE => $data,
	   IS_DESIGNING => $self->is_designing,
	   OWNER => $self
	  ) || throw Oak::Component::Error::ErrorCreatingOwned -text => $data->{name};
}

=over

=item after_construction

Overrided to dispatch the ev_onCreate event.

=back

=cut

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
			throw Oak::Component::Error::AlreadyRegistered -text => $p1->get('name');
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
		throw Oak::Component::Error::NotRegistered -text => $key;
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
		throw Oak::Component::Error::NotRegistered -text => $key;
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
		eval $ev;
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
	my $self = shift;
	return "Missing __CLASSNAME__ property while trying to create owned ".$self->{-text};
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
	my $self = shift;
	return "Error requiring module. ".$self->{-text};
}

package Oak::Component::Error::ErrorCreatingOwned;
use base qw (Error);

=over

=item Oak::Component::Error::ErrorCreatingOwned

If the new of the class returns false, this error is raised.

=back

=cut

sub stringify {
	my $self = shift;
	return "Error creating object".$self->{-text};
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
	my $self = shift;
	return "This object already has an owner".$self->{-text};
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
	my $self = shift;
	return "This object is not registered".$self->{-text};
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
	my $self = shift;
	return "This key has been already registered.".$self->{-text};
}

package Oak::Component::Error::MissingComponentName;
use base qw (Error);

=over

=item Oak::Component::Error::MissingComponentName

Missing the name property

=back

=cut

sub stringify {
	my $self = shift;
	return "The name property is mandatory.".$self->{-text};
}


1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
