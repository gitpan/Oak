package Oak::Object;

use strict;

=head1 NAME

Oak::Object - Base for all Oak Perl Object Tree

=head1 SYNOPSIS

  use base qw(Oak::Object);

=head1 DESCRIPTION

This is the base object for all the Oak Project, it implements
a set of primary functions, that will provide the main functionallity
of all Oak objects.

=head1 OBJECT METHODS

Oak::Object implements the following methods

=over 4

=item new(PARAMS)

This method should not be overriden by any module. It calls
constructor passing all the parameters it received and then
calls after_construction and returns the object reference.
This method also creates a mandatory property __CLASSNAME__,
that will be used in the internals of Oak.

=back

=cut

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	my $ret;
	$self->{__properties__}{__CLASSNAME__} = ref($self);
	$self->constructor(@_);
	$self->after_construction;
	return $self;
}

=over 4

=item constructor(PARAMS)

This method is called automatically from new. You should not call
it unless you know what you are doing. The return of this function
is not checked.  If you want to raise an error use throw (see L<Error>).

MUST CALL SUPER IN THE FUNCTION IF YOU OVERRIDES IT

=back

=cut

sub constructor {
	# Abstract function.
	return 1;
}

=over 4

=item after_construction

This method is called just after constructor. The return of this function
will be treated in the same way of constructor.

MUST CALL SUPER IN THE FUNCTION IF YOU OVERRIDES IT

=back

=cut

sub after_construction {
	# Abstract function
	return 1;
}

=over 4

=item message(MESSAGE)

Receives MESSAGE and execute some action associated with that message. Abstract
in Oak::Object, but you can override it to provide new message handlers. But
remember to call SUPER always you override this function.

=back

=cut

sub message {
	# Abstract function
}

=over 4

=item assign(OBJECT)

Assign all OBJECT properties to this object

=back

=cut

sub assign {
	my $self = shift;
	my $obj = shift;
	foreach my $p ($obj->get_property_array) {
		$self->set($p => $obj->get($p));
	}
}

=over 4

=item get_property_array

Returns an array with all existent properties. Actually, it really uses 
keys of the hash $self->{__properties__}.

=back

=cut

sub get_property_array {
	my $self = shift;
	$self->{__properties__} ||= {};
	return keys %{$self->{__properties__}};
}

=over 4

=item get(NAME,NAME,...)

Returns a scalar if one parameter is passed, or an array if more.
Do not override this function, override get_hash instead, this function
is only a wraper.

=back

=cut

sub get {
	my $self = shift;
	my @ret;
	my %retorno = $self->get_hash(@_);
	foreach my $p (keys %retorno) {
		push @ret, $self->{__properties__}{$p};
	}
	if (scalar @ret == 1) {
		return $ret[0];
	} else {
		return @ret;
	}
}

=over 4

=item get_hash(NAME,NAME,...)

Retuns a hash with all the properties requested. This function is called by
get.

=back

=cut

sub get_hash {
	my $self = shift;
	my %ret;
	foreach my $p (@_) {
		$ret{$p} = $self->{__properties__}{$p};
	}
	return %ret;
}

=over 4

=item set(NAME=>VALUE,NAME=>VALUE,...)

Sets a property in the object. Returns true if success.

=back

=cut

sub set {
	my $self = shift;
	my %args = @_;
	foreach my $p (keys %args) {
		$self->{__properties__}{$p} = $args{$p};
	}
}

=over 4

=item hierarchy_tree

Returns an array containing the tree of inheritance of the actual object.
Including the actual object. Nice to determine the path where the object
searches for methods.

=back

=cut

sub hierarchy_tree {
	my $self = shift;
	my $actual = ref($self) || $self;
	my @h;
	my @isa = eval("\@".$actual."::ISA");
	push @h, $actual;
	foreach my $i (@isa) {
		@h = ($i->hierarchy_tree,@h);
	}
	return @h;
}

=over

=item instance_of(CLASS)

Tests if this object or any of its superclasses is a instance of CLASS

=back

=cut

sub instance_of {
	my $self = shift;
	my $class = shift;
	foreach my $c ($self->hierarchy_tree) {
		return 1 if $c eq $class;
	}
	return 0;
}

=over

=item DESTROY

Always you implement DESTROY function, remember to call SUPER.

=back

=cut

=head1 EXCEPTION HANDLING

Oak uses the module L<Error> to handle the exceptions with the
syntax try/throw/catch/except/otherwise/finally. And in this case
all the errors must be classes. And this module introduces some 
(for now, just one :).

=over

=item Oak::Error::ParamsMissing

This class is used in the constructors if the required params were not passed.

=back

=cut

package Oak::Error::ParamsMissing;

use base qw (Error);

sub stringify {
	return "Missing parameters";
}

1;

__END__

=head1 BUGS

Too early to determine. :)

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
Aguimar Mendonca Neto <aguimar@email.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
