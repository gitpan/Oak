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
In case of any exception in this routines, it will call
call_exception passing the return of the function which failed.

=back

=cut

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	my $ret;
	$ret = $self->constructor(@_);
	unless ($ret) {
		$self->call_exception($ret);
		return undef;
	}
	$ret = $self->after_construction;
	unless ($ret) {
		$self->call_exception($ret);
		return undef;
	}
	return $self;
}

=over 4

=item constructor(PARAMS)

This method is called automatically from new. You should not call
it unless you know what you are doing. It MUST return a true value
in case of success. In case of failure, the return of this function
will be passed to call_exception.

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

=item call_exception(MESSAGE)

Handles an exception with code MESSAGE. The default handler is die MESSAGE.
If you override this function, remember to call SUPER if you do not 
find MESSAGE in the exception table.

=back

=cut

sub call_exception {
	my $self = shift;
	my $msg = shift;
	die $msg;
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

=item DESTROY

Always you implement DESTROY function, remember to call SUPER.

=back

=cut

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
