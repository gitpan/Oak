package Oak::Filer::DBI;

use base qw(Oak::Filer);
use Error qw(:try);
use DBI;

use strict;

=head1 NAME

Oak::Filer::DBI - Filer to save/load data into/from DBI tables

=head1 SYNOPSIS

  require Oak::Filer::DBI;

  my $filer = new Oak::Filer::DBI
   (
    io => $iodbiobj,		# mandatory, an Oak::IO::DBI object.
    table => "tablename",	# mandatory to enable load and store.
				#   table to work in selects and updates
    where => {primary => value},# this option must be passed to
				#   enable load and store functions.
				#   name and value of the keys to where sql clause
   )
    
  my $nome = $filer->load("nome");
  $filer->store(nome => lc($nome));

=head1 DESCRIPTION

This module provides access for saving data into a DBI table, to be used by
a Persistent descendant to save its data. Must pass table, prikey and privalue

=head1 OBJECT METHODS

=over 4

=item constructor(PARAMS)

Called by new. You do not want do call it by yourself.
Prepare to work with determined table and register (setted by privalue).

Could raise the Oak::Error::ParamsMissing exception.

=back

=cut

sub constructor {
	my $self = shift;
	my %params = @_;
	$self->set		# Avoid inexistent properties
	  (
	   io => $params{io},
	   where => $params{where},
	   table => $params{table},
	   prikey => $params{prikey},
	   privalue => $params{privalue}
	  );
	$self->get('io') || throw Oak::Error::ParamsMissing;
}


=over

=item load(FIELD,FIELD,...)

Loads one or more properties of the selected DBI table with the selected WHERE statement.
Returns a hash with the properties.

see do_sql for possible exceptions.

=back

=cut

sub load {
	my $self = shift;
	my $table = $self->get('table');
	my $where = $self->make_where_statement;
	return {} unless $table && $where;
	my @props = @_;
	my $fields = join(',',@props);
	my $sql = "SELECT $fields FROM $table WHERE $where";
	my $sth = $self->get('io')->do_sql($sql);
	return () unless $sth->rows;
	return %{$sth->fetchrow_hashref};
}

=over

=item store(FIELD=>VALUE,FIELD=>VALUE,...)

Saves the data into the selected table with the selected WHERE statement.

see do_sql for possible exceptions.

=back

=cut

sub store {
	my $self = shift;	
	my $table = $self->get('table');
	my $where = $self->make_where_statement;
	return 0 unless $table && $where;
	my %args = @_;
	my @fields;
	foreach my $p (keys %args) {
		$args{$p} = $self->get('io')->quote($args{$p});
		push @fields, "$p=$args{$p}"
	}
	my $set = join(',', @fields);
	my $sql = "UPDATE $table SET $set WHERE $where";
	$self->get('io')->do_sql($sql);
	return 1;
}

#internal function
sub make_where_statement {
	my $self = shift;
	my $where;
	my @fields;
	my $hr_where = $self->get('where');
	return 0 unless ref $hr_where;
	foreach my $w (keys %{$hr_where}) {
		push @fields, $w."=".$self->get('io')->quote($hr_where->{$w});
	}
	return join(' AND ',@fields);
}

1;

__END__

=head1 BUGS

Too early to know...

=head1 COPYRIGHT

Copyright (c) 2001 Daniel Ruoso <daniel@ruoso.com> and Rodolfo Sikora <rodolfo@trevas.net>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
