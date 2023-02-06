#!/usr/bin/env perl

use strict;
use warnings;
use lib './lib';
use File::Basename qw/dirname/;
use FindBin qw/$RealBin/;
use Data::Dumper;
use Digest::MD5 qw/md5_hex/;
use File::Temp qw/tempdir/;

use Test::More tests => 2;

$ENV{PATH} = "$RealBin/../scripts:".$ENV{PATH};
my $thisDir = dirname($0);

my $tempdir = tempdir("HASH2SEQ.XXXXXX", CLEANUP=>1, DIR=>$thisDir);
# Fake simple reference sequence
my $ref = 'TTCCGGTT';
my $refLength = length($ref);

# Write the fake reference file
open(my $fh, ">", "$tempdir/ref.fasta") or die "ERROR: could not write to $tempdir/ref.fasta: $!";
print $fh ">ref\n$ref";
close $fh;

subtest 'single mutation' => sub{
  plan tests=>$refLength;

  # Mutate one base at a time and see if the script is correct
  for(my $i=0;$i<length($ref);$i++){
    # Copy the reference allele and mutate one nucleotide
    my $allele = $ref;
    substr($allele,$i,1) = 'A';

    my $hash = md5_hex($allele);

    my $obs = `hash2seq.pl --max-snps 1 $tempdir/ref.fasta $hash`;
    chomp($obs);
    my($obsHash, $obsAllele) = split(/\t/, $obs);

    is($allele, $obsAllele, "Sequence for $hash");
  }

};

subtest 'two mutations' => sub{
  plan tests=>$refLength-1;

  # The first mutation is always going to be a C in the first position
  # And then the rest will be mutated again
  substr($ref,0,1) = "C";

  # Mutate one base at a time and see if the script is correct
  for(my $i=1;$i<$refLength;$i++){
    # Copy the reference allele and mutate one nucleotide
    my $allele = $ref;
    substr($allele,$i,1) = 'A';

    my $hash = md5_hex($allele);

    my $obs = `hash2seq.pl --max-snps 2 $tempdir/ref.fasta $hash`;
    chomp($obs);
    my($obsHash, $obsAllele) = split(/\t/, $obs);

    is($allele, $obsAllele, "Sequence for $hash");
  }

};

