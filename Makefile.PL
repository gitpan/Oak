use ExtUtils::MakeMaker;

my $mm = new MM
 (
  {
   AUTHOR => "Daniel Ruoso <daniel\@ruoso.com>",
   ABSTRACT => "Perl Oak Component Tree",
   NAME => "Oak",
   NORECURS => "true",
   PMLIBDIRS => ['IO','Filer'],
   VERSION => "1.2-fix2",
   PREREQ_PM => 
   {
    'XML::Writer' => '0',
    'XML::Parser' => '0',
    'DBI' => '0',
    'IO' => '0',
    'Error' => '0',
    'Carp' => '0'
   }
  }
 );

$mm->flush;

# I had to overwrite this function, because this
# is a package and not just a module.

sub MM::init_main {
	package MM; # so that "SUPER" works right
	my $self = shift;
	my $return = $self->SUPER::init_main();
	$self->{NAME}="Oak";
	$self->{PARENT_NAME}="Oak";
	$self->{BASEEXT}="";
	return $return;
}

sub MM::init_dirscan {
	package MM; # so that "SUPER" works right
	my $self = shift;
	my $return = $self->SUPER::init_dirscan();
	# We know that the only dir here is Web,
	# because it contains a Makefile.PL
	# So, we'll avoid it
	if (ref $self->{DIR} eq "ARRAY") {
		my @new;
		foreach my $k (@{$self->{DIR}}) {
			push @new, $k unless $k eq "Web";
		}
		$self->{DIR} = \@new;
	}
	return $return;
}
