use ExtUtils::MakeMaker;

my $mm = new MM
 (
  {
   AUTHOR => "Daniel Ruoso <daniel\@ruoso.com>",
   ABSTRACT => "Perl Oak Component Tree",
   NAME => "Oak",
   VERSION => "1.6",
   PREREQ_PM => 
   {
    'XML::Writer' => '0',
    'XML::Parser' => '0',
    'DBI' => '0',
    'IO' => '0',
    'Error' => '0.15',
    'Carp' => '0'
   }
  }
 );

$mm->flush;
