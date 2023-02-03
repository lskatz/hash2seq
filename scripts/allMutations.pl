use strict;
use warnings;
use Getopt::Long qw/GetOptions/;
use Data::Dumper;

sub logmsg{print STDERR "$0: @_\n"}
exit(main());

sub main{
  my $settings = {};
  GetOptions($settings, qw(help num-mutations=i)) or die $!;
  $$settings{'num-mutations'} ||= 1;

  if(!@ARGV || $$settings{help}){
    print "Usage: $0 [options] SEQUENCE
    SEQUENCE            a sequence of DNA

    --num-mutations  1  Number of mutations to introduce
    \n";
    exit 0;
  }

  my $sequence = shift(@ARGV);
  
  # Get combinations
  logmsg "Mutating ".$$settings{'num-mutations'}." in sequence:\n $sequence\n";
  my @combinations = dna_mutations($sequence, $$settings{'num-mutations'}, 0);

  # Print the list of combinations
  foreach my $combination (@combinations) {
    print "$combination\n";
  }
    
  return 0;
}


sub dna_mutations {
  my ($dna, $num_mutations, $start) = @_;

  # The four possible nucleotides
  my @nucleotides = ('A', 'C', 'G', 'T');

  # Create an array to store the combinations
  my @combinations;

  # Base case: if we have reached the desired number of mutations, add the new DNA sequence to the list of combinations
  if ($num_mutations == 0) {
    push @combinations, $dna;
    return @combinations;
  }

  # Loop through the sequence
  for (my $i = 0; $i < length($dna); $i++) {
    # Loop through the nucleotides
    foreach my $nucleotide (@nucleotides) {
      # Skip if the nucleotide is already present
      next if substr($dna, $i, 1) eq $nucleotide;

      # Create a new DNA sequence with the mutation
      my $new_dna = substr($dna, 0, $i) . $nucleotide . substr($dna, $i + 1);

      # Recursively call the subroutine to find the remaining mutations
      push @combinations, dna_mutations($new_dna, $num_mutations - 1, $i + 1);
    }
  }

  return @combinations;
}

