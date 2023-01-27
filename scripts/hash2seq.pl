#!/usr/bin/env perl 

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename qw/basename/;

use Digest::MD5 qw/md5_hex/;

use version 0.77;
our $VERSION = '0.1.1';

our @NT = qw(A C G T);

local $0 = basename $0;
sub logmsg{local $0=basename $0; print STDERR "$0: @_\n";}
exit(main());

sub main{
  my $settings={};
  GetOptions($settings,qw(max-snps=i help)) or die $!;
  usage() if($$settings{help} || @ARGV < 2);

  $$settings{'max-snps'} ||= 5;

  my $refFasta = shift(@ARGV);
  my $refSequence = readSingleSequence($refFasta, $settings);

  for my $hash(@ARGV){
    $hash = lc($hash);
    my $seq = hash2seq($refSequence, $hash, $$settings{'max-snps'}, $settings);
    print join("\t", $hash, $seq)."\n";
  }

  return 0;
}

# quick and dirty to read a single entry in a fasta file
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
  

sub hash2seq{
  my($refSequence, $hash, $maxSnps, $settings) = @_;

  my $seqLength = length($refSequence);
  my $currentMutationCount = 0;

  for(my $i=0; $i<$seqLength; $i++){

    # Reset to the reference before any SNPs are introduced
    my $newSequence = $refSequence;
    for my $nt(@NT){
      # introduce the first mutation
      substr($newSequence, $i, 1) = $nt;
      #logmsg $newSequence;

      if(checkHash($newSequence, $hash)){
        #logmsg "Found sequence! $newSequence";
        return $newSequence;
      }
    }
  }
  
  return 0;
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

  --max-snps  How many SNPs to mutate away from the reference sequence
              Default: 3
  --help      This useful help menu
  \n";
  exit 0;
}
