package Oak::Controller::EntityHelper;

use Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(list list_related create purge get_data set_data add_relationship remove_relationship);
use strict;

=head1 NAME

Oak::Controller::EntityHelper - Helper module for accessing DBIEntities from Controller

=head1 SYNOPSIS

  # This class do not catch any exception, all the exeptions thrown by the entity classes
  # will be propagated
  #########################
  # in the controller...

  use Oak::Controller::EntityHelper qw(list list_related create purge get_data set_data);

  $bag = $self->list
  (
   class => "MyApp::MyDBIEntityClass",
   query => "LIMIT 10, 10 ORDER BY name"
  );

  $bag = $self->list_related
  (
   class => "MyApp::MyDBIEntityClass",
   keys => {myprimary_key => "my_value"},
   query => "LIMIT 10, 10 ORDER BY name",
   relationship => "relationship_name"
  );

  $bag = $self->create
  (
   class => "MyApp::MyDBIEntityClass",
   data => {field1 => "value1"}
  );

  $bag = $self->purge
  (
   class => "MyApp::MyDBIEntityClass",
   keys => {myprimary_key => "my_value"}
  );

  $bag = $self->get_data
  (
   class => "MyApp::MyDBIEntityClass",
   keys => {myprimary_key => "my_value"}
  );

  $bag = $self->set_data
  (
   class => "MyApp::MyDBIEntityClass",
   keys => {myprimary_key => "my_value"},
   data => {myfield => "myvalue"}
  );


=head1 DESCRIPTION

This is a helper module that exports the methods "list", "list_related", "get_data", "set_data" and "count".
Create methods that calls these methods in your controller class.

=head1 EXPORTED METHODS

=over

=item list(class => "MyApp::MyDBIEntityClass", query => "LIMIT 10, 10 ORDER BY name")

This methods returns an array of hashes containing the information about the objects in the specified class.

  [
   {field1 => "value1",field2 => "value2"},
   ...
  ]

=back

=cut

sub list {
	my $self = shift;
	my %params = @_;
	my $entity_name = $params{class};
	my $query = $params{query};
	eval "require $entity_name;";
	my @objects = $entity_name->List($query);
	my $bag = [];
	foreach my $o (@objects) {
		push @{$bag}, {$o->get_hash($o->get_property_array)};
	}
	return $bag;
}

=over

=item list_related(class => "MyApp::MyDBIEntityClass", keys => {myprimary_key => "my_value"}, query => "LIMIT 10, 10 ORDER BY name", relationship => "relationship_name")

This methods returns an array of hashes containing the information about the objects in the specified relationship of the specified object (class and keys).

  [
   {field1 => "value1",field2 => "value2"},
   ...
  ]

=back

=cut

sub list_related {
	my $self = shift;
	my %params = @_;
	my $entity_name = $params{class};
	my $keys = $params{keys};
	$keys = {} unless ref $keys eq "HASH";
	my $query = $params{query};
	my $relationship = $params{relationship};
	eval "require $entity_name";
	my $object = $entity_name->new(%{$keys});
	my @objects = $object->list_related($relationship,$query);
	my $bag = [];
	foreach my $o (@objects) {
		push @{$bag}, {$o->get_hash($o->get_property_array)};
	}
	return $bag;
}

=over

=item create(class => "MyApp::MyDBIEntityClass", data => {myfield1 => "myvalue1"})

This method create a object of the specified class with the specified data.

=back

=cut

sub create {
	my $self = shift;
	my %params = @_;
	my $entity_name = $params{class};
	my $data = $params{data};
	$data = {} unless ref $data eq "HASH";
	eval "require $entity_name";
	return $entity_name->new(create => $data);
}

=over

=item purge(class => "MyApp::MyDBIEntityClass", keys => {myprimary_key => "my_value"})

This method will purge the specified object from the specified class.

=back

=cut

sub purge {
	my $self = shift;
	my %params = @_;
	my $entity_name = $params{class};
	my $keys = $params{keys};
	$keys = {} unless ref $keys eq "HASH";
	eval "require $entity_name";
	my $obj = $entity_name->new(%{$keys});
	$obj->purge;
}

=over

=item get_data(class => "MyApp::MyDBIEntityClass", keys => {myprimary_key => "my_value"})

This method will return a hashref with the object data.

=back

=cut

sub get_data {
	my $self = shift;
	my %params = @_;
	my $entity_name = $params{class};
	my $keys = $params{keys};
	$keys = {} unless ref $keys eq "HASH";
	eval "require $entity_name";
	my $obj = $entity_name->new(%{$keys});
	return {$obj->get_hash($obj->get_property_array)};
}

=over

=item set_data(class => "MyApp::MyDBIEntityClass", keys => {myprimary_key => "my_value"}, data => {myfield1 => "myvalue1"})

This method will set the passed data to the specified object.

=back

=cut

sub set_data {
	my $self = shift;
	my %params = @_;
	my $entity_name = $params{class};
	my $keys = $params{keys};
	$keys = {} unless ref $keys eq "HASH";
	my $data = $params{data};
	$data = {} unless ref $data eq "HASH";
	eval "require $entity_name";
	my $obj = $entity_name->new(%{$keys});
	$obj->set(%{$data});
}

1;

=over

=item remove_relationship("entity_class", {key1 => "value1", key2 => "value2", ...}, "related_class", {key1 => "value1", key2 => "value2", ...}, "Relationship name")

This one creates the DBIEntities with your respective class names ("entity_class" and "related_class") and builds a relationship between them through the given relationship name calling:


$entity->add_relationship("Relationship name", $related);


=back

=cut

sub add_relationship {
	my $self = shift;
	my @params = @_;
	eval "require $params[0]";
	my $entity = $params[0]->new(%{$params[1]});
	eval "require $params[2]";
	my $related = $params[2]->new(%{$params[3]});
	$entity->add_relationship($params[4], $related);
}

=over

=item add_relationship("entity_class", {key1 => "value1", key2 => "value2", ...}, "related_class", {key1 => "value1", key2 => "value2", ...}, "Relationship name")

This one creates the DBIEntities with your respective class names ("entity_class" and "related_class") and destroys the relationship (named by the given relationship name) between them calling:


$entity->remove_relationship("Relationship name", $related);


=back

=cut

sub remove_relationship {
	my $self = shift;
	my @params = @_;
	eval "require $params[0]";
	my $entity = $params[0]->new(%{$params[1]});
	eval "require $params[2]";
	my $related = $params[2]->new(%{$params[3]});
	$entity->remove_relationship($params[4], $related);
}

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
Carlos Eduardo de Andrade Brasileiro <eduardo@oktiva.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
