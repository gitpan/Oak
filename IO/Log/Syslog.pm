package Oak::IO::Log::Syslog;

use strict;
use Sys::Syslog;
use base qw(Oak::IO::Log);

=head1 NAME

Oak::IO::Log::Syslog - Oak interface to Sys::Syslog

=head1 DESCRIPTION

This component implements an interface with the Sys::Syslog
perl module. It is a component, so you can save its properties
in a xml file (probably of a datamodule);

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::IO::Log|Oak::IO::Log>

L<Oak::IO::Log::Syslog|Oak::IO::Log::Syslog>


=head1 PROPERTIES

Whenever you change any of this properties, the log will be closed
and then opened again.

P.S.: Pass this properties when creating a object

=over

=item ident

Identification of the log. Usually the name of the application

=item logopt

contains zero or more of the words pid, ndelay, cons, nowait
see Sys::Syslog for more info

=item facility

specifies the part of the system

=back

=head1 METHODS

=cut

sub constructor {
	my $self = shift;
	my %params = shift;
	$self->SUPER::constructor(%params);
	unless (ref $params{RESTORE} eq "HASH") {
		$self->feed
		  (
		   ident => $params{ident},
		   logopt => $params{logopt},
		   facility => $params{facility},
		  );
	}
	openlog($self->get("ident"), $self->get("logopt"), $self->get("facility"));
}

=over

=item log(PRIORITY, MESSAGE, ARGS)

This function will call syslog with the given parameters.
See Sys::Syslog for more info

=back

=cut

sub log {
	my $self = shift;
	syslog(@_);
}

sub set {
	my $self = shift;
	my %params = @_;
	$self->SUPER::set(%params);
	closelog;
	openlog($self->get("ident"), $self->get("logopt"), $self->get("facility"));
}

1;

__END__

=head1 RESTRICTIONS

As Sys::Syslog is not object oriented, and there is no way of getting
a reference to the current syslog options. You can use just one
Oak::IO::Log::Syslog object per application. Or else you will get the
messages of one object falling into other log.

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


