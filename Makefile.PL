use ExtUtils::MakeMaker;

my $mm = new MM
 (
  {
   AUTHOR => "Daniel Ruoso <daniel\@ruoso.com>",
   ABSTRACT => "Perl Oak Component Tree",
   NAME => "Oak",
   VERSION => "1.7",
   PREREQ_PM => 
   {
    'XML::Writer' => '0',
    'XML::Parser' => '0',
    'IO' => '0',
    'Error' => '0.15',
   }
  }
 );

$mm->flush;
