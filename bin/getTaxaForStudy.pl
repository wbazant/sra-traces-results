#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

use FindBin;
use lib "$FindBin::Bin/../lib";
use SraTraces;

use LWP::Simple;

use Getopt::Long;

my $study;
my $runIdsString;
my $runsPath;
my $includeRareTaxa = 0;
my $doTotals = 0;

sub usage {
  die join(" ", @_, "Usage: $0 [--study studyAccession] [--runIds r1,r2,r3 ] [--runsPath runs.tsv] [--includeRareTaxa] [--doTotals]"); 
}
GetOptions (
  "study=s" => \$study,
  "runIds=s" => \$runIdsString,
  "runsPath=s" => \$runsPath,
  "includeRareTaxa" => \$includeRareTaxa,
  "doTotals" => \$doTotals,
) or die("Error in command line arguments\n");

my @runs;
if($study){
  @runs = grep {/([DES]RR\d+)/} split "\n", get("https://www.ebi.ac.uk/ena/portal/api/filereport?accession=$study&result=read_run&fields=run_accession&format=tsv&download=true");
} elsif ($runIdsString){
  @runs = split ",", $runIdsString;
} elsif ($runsPath){
  open (my $fh, "<", $runsPath) or die "$!: $runsPath";
  @runs = split "\n", do { local $/; <$fh>};
} else {
  usage("No runs specified!");
}




my %allAbundances;

for my $run (@runs){
  my $page = get("https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=$run");
  my $taxonAbundances = taxonAbundancesFromPage($page, $includeRareTaxa, $doTotals);
  for my $taxon (keys %{$taxonAbundances}){
     $allAbundances{$taxon}{$run} = $taxonAbundances->{$taxon};
  }
}

say join "\t", "", @runs;

sub fmt {
  my ($num, $includeRareTaxa) = @_;
  my $f = $includeRareTaxa ? "%d" : "%.4f";
  return $num ? sprintf($f, $num) : "";
}
for my $taxon (sort keys %allAbundances){
  say join "\t", $taxon, map {fmt($allAbundances{$taxon}{$_} , $includeRareTaxa)} @runs;
}
