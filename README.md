# hash2seq
figure out what your sequence is from the hash

# Usage

```text
hash2seq.pl: brute forces a sequence given a reference sequence and a hash
  Usage: hash2seq.pl [options] ref.fasta hash1 [hash2...]
  NOTE: ref.fasta nucleotides will be transformed into uppercase for hashing.

  --quick-stop Stop if the hash was found. Assume no collisions.
               This hasn't been benchmarked, but I assume it is faster.
  --max-snps   Max num of SNPs to mutate away from the reference sequence
               Default: 3
  --print-all  Print all combinations of sequences with their hashes
               and then exit.
  --help       This useful help menu
```

```text
$ perl scripts/hash2seq.pl --max-snps 1 t/senterica/aroC.tfa d85fab85b29a8c26f89a4a3b46ec36a6
d85fab85b29a8c26f89a4a3b46ec36a6        GTTTTTCGCCCGGGACACGCGGATTACACCTATGAGCAGAAATACGGCCTGCGCGATTACCGCGGCGGTGGACGTTCTTCCGCGCGTGAAACCGCGATGCGCGTAGCGGCAGGGGCGATCGCCAAGAAATACTTGGCGGAAAAGTTCGGCATCGAAATCCGCGGCTGCCTGACCCAGATGGGCGACATTCCGCTGGAGATTAAAGACTGGCGTCAGGTTGAGCTTAATCCGTTCTTTTGCGCCGATGCGGACAAACTTGACGCGCTGGACGAACTGATGCGCGCGCTGAAAAAAGAGGGTGACTCCATCGGCGCGAAAGTGACGGTGATGGCGAGCGGCGTGCCGGCAGGGCTTGGCGAACCGGTATTTGACCGACTGGATGCGGACATCGCCCATGCGCTGATGAGCATCAATGCGGTGAAAGGCGTGGAGATCGGCGAAGGATTTAACGTGGTGGCGCTGCGCGGCAGCCAGAATCGCGATGAAATCACGGCGCAGGGT
```
