package Oak::IO::DBI;

use base qw(Oak::Component);
use Error qw(:try);
use DBI;

use strict;

=head1 NAME

Oak::IO::DBI - IO routines to exchange data with databases using DBI

=head1 SYNOPSIS

  require Oak::IO::DBI;

  my $io = new Oak::IO::DBI
   (
    name     => "IODBI",	# mandatory (see Oak::Component)
    dbdriver => "mysql",	# mandatory, any supported by DBI
    database => "mydatabase",	# mandatory
    hostname => "hostname",	# mandatory
    username => "dbusername",	# optional
    password => "userpasswd",	# optional
    options => { DBI OPTIONS },	# optional. A hash reference to DBI options
   )

  P.S.: In the case of the automatic creation by an owner object all the
  properties will be passed through the RESTORE hash and the OWNER variable.
  See Oak::Component.

=head1 DESCRIPTION

This module provides access for exchange data with databases using DBI.

=head1 OBJECT PROPERTIES

=over 4

=item datasource (readonly)

DBI datasorce string, used to create the connection, 
defined using the parameters passed to new.

=item hostname,database,dbdriver,username,password,options

DBI options. See DBI documentation for more help.

=head1 OBJECT METHODS

=over 4

=item constructor(PARAMS)

Called by new. You do not want do call it by yourself. Generates
a onCreate event.

Could raise the Oak::Error::ParamsMissing exception.

=back

=cut

sub constructor {
	my $self = shift;
	my %params = @_;
	$self->SUPER::constructor(%params);
	unless (ref $params{RESTORE} eq "HASH") {
		unless ($self->_test_required_params(%params)) {
			throw Oak::Error::ParamsMissing;
		}
		$self->set	# Avoid inexistent properties
		  (
		   hostname => $params{hostname},
		   database => $params{database},
		   dbdriver => $params{dbdriver},
		   username => $params{username},
		   password => $params{password},
		   options => $params{options},
		  );
	}
	$self->connect;
	if ($self->get('onCreate')) {
		my $str = $self->get('onCreate').'($self)';
		eval $str;
	}
}

# internal function
sub _test_required_params {
	my $self = shift;
	my %params = @_;
	return undef unless (
			     $params{dbdriver} &&
			     $params{database} &&
			     $params{hostname}
			    );
	return 1;
}

=over

=item connect

Register the connection for this object. Generates an onConnect event.

Could raise the Oak::IO::DBI::Error::ConnectionFailure exception.

=back

=cut

sub connect {
	my $self = shift;

	$self->{dbh} ||= DBI->connect (
				      $self->get('datasource'),
				      $self->get('username'),
				      $self->get('password'),
				      $self->get('options')
				     );
	unless ($self->{dbh}) {
		throw Oak::IO::DBI::Error::ConnectionFailure; # Must raise the exception
	}
	if ($self->get('onConnect')) {
		my $str = $self->get('onConnect').'($self)';
		eval $str;
	}

	return 1;
}

=over

=item do_sql(SQL)

Prepare, executes and test if successfull. Returns the Sth.
Generates an onSql event (passes $sql and $sth to the function called).

Could rause the following exceptions:
Oak::Filer::DBI::Error::SQLSyntaxError and Oak::Filer::DBI::Error::SQLExecuteError

=back

=cut

sub do_sql {
	my $self = shift;
	my $sql = shift;
	$self->connect;
	my $sth = $self->{dbh}->prepare($sql);
	throw Oak::IO::DBI::Error::SQLSyntaxError -text => $sql unless defined $sth;
	my $rv = $sth->execute;
	throw Oak::IO::DBI::Error::SQLExecuteError -text => $sql unless (defined $sth) and ($rv);
	if ($self->get('onSql')) {
		my $str = $self->get('onSql').'($self,$sql,$sth)';
		eval $str;
	}
	return $sth;
}

# does not need documentation, this implementation is only used internally.
sub get_hash {
	my $self = shift;
	my @props = @_;
	for (@props) {
		/^datasource$/ && do {
			$self->{__properties__}{$_} = "DBI:".$self->get('dbdriver').":database=".$self->get('database').";host=".$self->get('hostname');
			next;
		}
	}
	return $self->SUPER::get_hash(@props);
}

=over

=item quote

Quotes a string, using DBI->quote unless empty, else uses "''".

=back

=cut

sub quote {
	my $self = shift;
	my $str = shift;
	$self->connect;
	unless (($str eq '') || (!defined $str)) {
		$str = $self->{dbh}->quote($str);
	} else {
		$str = "''";
	}
	return $str;
}

=over

=item get_dbh

Returns the DBI object.

=back

=cut

sub get_dbh {
	my $self = shift;
	$self->connect;
	return $self->{dbh};
}


=over

=item disconnect

Called by DESTROY, releases the DBI connection. It disconnects.
Generates a onDisconnect event.

=back

=cut

sub disconnect {
	my $self = shift;
	$self->{dbh}->disconnect if $self->{dbh};
	$self->{dbh} = undef;
	if ($self->get('onDisconnect')) {
		my $str = $self->get('onDisconnect').'($self)';
		eval $str;
	}
	return 1;
}

=over

=item DESTROY

Disconnects and generates a onDestroy event.

=back

=cut

sub DESTROY {
	my $self = shift;
	return $self->disconnect;
	if ($self->get('onDestroy')) {
		my $str = $self->get('onDestroy').'($self)';
		eval $str;
	}
	$self->SUPER::DESTROY;
}

1;

=head1 EXCEPTION HANDLING

=over

=item Oak::IO::DBI::Error::ConnectionFailure;

This class is used in the register_connection when it fails

=back

=cut

package Oak::IO::DBI::Error::ConnectionFailure;

use base qw (Error);

sub stringify {
	return "Connection Failure";
}

package Oak::IO::DBI::Error::SQLSyntaxError;

=over

=item Oak::IO::DBI::Error::SQLSyntaxError;

This class is raised when the sql has wrong syntax

=back

=cut

use base qw (Error);

sub stringify {
	return "Syntax Error";
}

package Oak::IO::DBI::Error::SQLExecuteError;

=over

=item Oak::IO::DBI::Error::SQLExecuteError;

This class is raised when the sql has an error while executing

=back

=cut

use base qw (Error);

sub stringify {
	return "Execute Error";
}

__END__

=head1 BUGS

Too early to know...

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com> and Rodolfo Sikora <rodolfo@trevas.net>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
