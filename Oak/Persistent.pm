package Oak::Persistent;

use strict;
use base qw(Oak::Object);

=head1 NAME

Oak::Persistent - Implements persistency in object properties

=head1 DESCRIPTION

This module is the base for all objects that needs persistency.
It implements the basic functions to store the object data.

=head1 METHODS

Oak::Persistent inherits all Oak::Object methods and implements/overrides
the following

=over

=item after_construction

Overwritten only to call load_initial_properties, you need to call SUPER at
the beggining of the function if you overrides it

=back

=cut

sub after_construction {
	my $self = shift;
	$self->SUPER::after_construction;
	$self->load_initial_properties;
	return 1;
}

=over

=item load_initial_properties

This function is called at after_construction to load the properties that
always will be used by the object. Simply call get with all the
properties you need.

=back

=cut

sub load_initial_properties {
	# Abstract function
	return 1;
}

=over

=item get_hash(NAME,NAME,...)

Overriden just to call load_property if the requested property is
not in the object property hash. 

=back

=cut

sub get_hash {
	my $self = shift;
	my @a = @_;
	my @b;
	my %f;
	foreach my $p (@a) {
		if (
		    (not exists $self->{__properties__}{$p})
		   ) {
			push @b, $p;
		}
	}
	foreach my $p (@b) {
		my $filer = $self->choose_filer($p);
		$self->test_filer($filer);
		$f{$filer} ||= [];
		push @{$f{$filer}},$p;
	}
	foreach my $fil (keys %f) {
		my @result = $self->{__filers__}{$fil}->load(@{$f{$fil}});
		if (scalar(@result) == 1) {
			next;
		} else {
			%{$self->{__properties__}} = (%{$self->{__properties__}},@result);
		}
	}
	return $self->SUPER::get_hash(@a);
}

=over

=item set(NAME=>VALUE,NAME=>VALUE,...)

Overriden to call chooseFiler and store with the selected filer.

=back

=cut

sub set {
	my $self = shift;
	my %args = @_;
	my %f;
	foreach my $p (keys %args) {
		my $filer = $self->choose_filer($p);
		$self->test_filer($filer);
		$f{$filer}{$p} = $args{$p};
	}
	foreach my $fil (keys %f) {
		$self->{__filers__}{$fil}->store(%{$f{$fil}});
	}
	$self->SUPER::set(%args); # just save $self->{__properties__}
}

=over

=item feed(NAME=>VALUE,NAME=>VALUE,...)

Defines a property without using any filer. Usefull at constructor, when you
want to set the properties you will use to create the filer. Or for objects
created that you already have the data (you made a optimized sql, and you have
the data of severall objects), this will make the object not to use the filer 
to access this property.

=back

=cut

sub feed {
	my $self = shift;
	my %feed = @_;
	return $self->SUPER::set(%feed);
}

=over

=item choose_filer(NAME)

Selects the filer which works with NAME property of object. Returns the name
of the filer.

=back

=cut

sub choose_filer {
	'default';
}

=over

=item test_filer(NAME)

Create the filer NAME unless exists and defined.

=back

=cut

sub test_filer {
	my $self = shift;
	my $name = shift;
	require Oak::Filer;
	# Oak filer is reliable. Does nothing.
	$self->{__filers__}{$name} ||= new Oak::Filer;
	return 1;
}

package Oak::Persistent::Error::ErrorCreatingFiler;
use base qw (Error);

=over

=item Oak::Persistent::Error::ErrorCreatingFiler

The filer was still undef after the creation.

=back

=cut

sub stringify {
	return "Error creating filer.";
}


1;

__END__

=head1 EXAMPLES

  use base qw(Oak::Persistent);

=head1 COPYRIGHT

Copyright (c) 2001 
Daniel Ruoso <daniel@ruoso.com>
Aguimar Mendonca Neto <aguimar@email.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
