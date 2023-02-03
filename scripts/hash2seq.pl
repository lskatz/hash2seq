#!/usr/bin/env perl 

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename qw/basename/;
use List::MoreUtils qw/uniq/;

use Digest::MD5 qw/md5_hex/;

use version 0.77;
our $VERSION = '0.2.0';

our @NT = qw(A C G T);

local $0 = basename $0;
sub logmsg{local $0=basename $0; print STDERR "$0: @_\n";}
exit(main());

sub main{
  my $settings={};
  GetOptions($settings,qw(print-all max-snps=i quick-stop help)) or die $!;
  usage() if($$settings{help} || @ARGV < 1);

  $$settings{'max-snps'} ||= 3;

  my $refFasta = shift(@ARGV);
  my $refSequence = readSingleSequence($refFasta, $settings);

  my @combinations = dna_mutations($refSequence, $$settings{'max-snps'}, 0);
  if($$settings{'print-all'}){
    printAllSequenceHashes(\@combinations);
    return 0;
  }

  # Look at lowercase hashes to standardize comparisons
  my @seqHash = map{lc($_)} @ARGV;

  if(@seqHash < 1){
    logmsg "WARNING: no hashes were supplied!";
    usage();
  }

  # Keep track of which hashes are missing seqs
  my %missingSeq = map{$_=>1} @seqHash;
  COMBINATION:
  for my $seq(@combinations){

    for my $hash(@seqHash){
      if(checkHash($seq, $hash)){
        print join("\t", $hash, $seq)."\n";
        #$hash_was_found = 1;

        # If quick stop, remove this hash from consideration
        # once found.
        if($$settings{'quick-stop'}){
          @seqHash = grep{$_ ne $hash} @seqHash;
          if(!@seqHash){
            last COMBINATION;
          }
        }
      }
    }
  }

  return 0;
}

sub printAllSequenceHashes{
  my($combinations) = @_;

  for my $c(@$combinations){
    print join("\t", $c, md5_hex($c))."\n";
  }

  return scalar(@$combinations);
}

# quick and dirty to read a single entry in a fasta file.
# Other sequences are ignored.
sub readSingleSequence{
  my($fasta, $settings) = @_;
  open(my $fh, $fasta) or die "ERROR: could not read $fasta: $!";

  my $defline = <$fh>;
  if($defline !~ /^>/){
    die "ERROR: $fasta does not look like a fasta file";
  }

  local $/ = undef;
  my $seq = <$fh>;
  $seq =~ s/\s+//g; # Remove any whitespace in the sequence
  $seq =~ s/>.*//;  # Remove anything after the second defline
  if($seq =~ /(\W+)/){
    die "ERROR: $fasta has some characters in the sequence that are not letters: '$1'";
  }

  return uc($seq);
}

# Make all possible DNA mutations in a sequence and
# return them in an array.
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

  @combinations = uniq(@combinations);
  return @combinations;
} 

sub checkHash{
  my($seq, $hash, $settings) = @_;
  #logmsg "$seq => ".md5_hex($seq);

  return(
    md5_hex($seq) eq $hash
  );
}

sub usage{
  print "$0: brute forces a sequence given a reference sequence and a hash
  Usage: $0 [options] ref.fasta hash1 [hash2...]
  NOTE: ref.fasta nucleotides will be transformed into uppercase for hashing.

  --quick-stop Stop if the hash was found. Assume no collisions.
               This hasn't been benchmarked, but I assume it is faster.
  --max-snps   Max num of SNPs to mutate away from the reference sequence
               Default: 3
  --print-all  Print all combinations of sequences with their hashes 
               and then exit.
  --help       This useful help menu
  \n";
  exit 0;
}
