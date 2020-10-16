#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

use FindBin;
use lib "$FindBin::Bin/../lib";
use SraTraces;

use LWP::Simple;


my ($study, $doRareTaxa) = @ARGV;
die "Usage: $0 <study eg. PRJNA645191> <get the rare taxa rather than skip them 1/0>"
  unless $study;

my @runs = grep {/SRR/} split "\n", get("https://www.ebi.ac.uk/ena/portal/api/filereport?accession=$study&result=read_run&fields=run_accession&format=tsv&download=true");


my %allAbundances;

for my $run (@runs){
  my $page = get("https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=$run");
  my $taxonAbundances = taxonAbundancesFromPage($page, $doRareTaxa);
  for my $taxon (keys %{$taxonAbundances}){
     $allAbundances{$taxon}{$run} = $taxonAbundances->{$taxon};
  }
}

say join "\t", "", @runs;

sub fmt {
  my ($num, $doRareTaxa) = @_;
  my $f = $doRareTaxa ? "%d" : "%.2f";
  return $num ? sprintf($f, $num) : "";
}
for my $taxon (sort keys %allAbundances){
  say join "\t", $taxon, map {fmt($allAbundances{$taxon}{$_} , $doRareTaxa)} @runs;
}
