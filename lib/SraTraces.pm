#! /usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use List::Util qw/sum/;
use JSON;
use YAML;

sub taxonAbundancesFromPage {
  my ($path, $doKbp) = @_;
  my @nodes = extractNodesFromTracesPage($path);

  my @lineages = assembleNodesIntoLineages(@nodes);

  my $result = dataToHash(percentFromLineages(@lineages));
  return $result unless $doKbp;

  my $resultKbp = dataToHash(kbpFromLineages(@lineages));

  my $kbpInOnePercent = estimateKbpInOnePercent(@lineages);

  for my $taxon (keys %{$result}) {
    $resultKbp->{$taxon} //= $result->{$taxon} * $kbpInOnePercent;
  }
  return $resultKbp;
}




sub extractNodesFromTracesPage {
  my ($page) = @_;
  my @pageLines = split "\n", $page;
  my @lines;
  my $on;
  # get the right piece of the page
  for (@pageLines){
    if (s{^.*var oTaxAnalysisData = .*}{}){
      $on=1;
    }
    if(m{utils.addEvent}){
      $on=0;
    }
    if($on){
      push @lines, $_;
    }
  }
  return unless @lines;

  # get the JSON, parse it in
  my $json = join("", @lines);
  $json =~s{;}{};
  $json = "[$json";

  # the tree is given as a list of nodes and their parents
  # but we want a list of taxon strings
  
  return grep {$_} map {@$_} decode_json($json);
}
1;

sub assembleNodesIntoLineages{
  my @nodes = @_;
  my %parentIds;
  $parentIds{$_->{n}}++ for @nodes;

  my @lineages;
  my @lineagesAll;

  @lineages = map {[$_]} grep {not $parentIds{$_->{p}} } @nodes;
  @nodes = grep {$parentIds{$_->{p}} } @nodes;
  push @lineagesAll, @lineages;
  while (@nodes){
    my %nodesAdded;
    my @nextLineages;
    NODE:

    for my $lineage (@lineages){
      my @extendedLineages;
      for my $node (@nodes) {
        if($lineage->[0]{n} eq $node->{p}){
           push @extendedLineages, [$node, @{$lineage}];
           $nodesAdded{$node->{n}}++;
        }
      }
      if (@extendedLineages){
        push @lineagesAll, @extendedLineages;
        push @nextLineages, @extendedLineages;
      } else {
        push @nextLineages, $lineage;
      }
    }
    unless(keys %nodesAdded){
      die Dump \@nodes, \@lineages;
    }
    @lineages = @nextLineages;
    @nodes = grep { not $nodesAdded{$_->{n}}} @nodes;
  }
  return @lineagesAll;
}

sub isSubTaxon {
  my ($str, $substr) = @_;
  return $str ne $substr && index($str, $substr) == 0;
}


sub percentFromLineages {
  my @lineagesAll = @_;
  my @data = map {my $lineage = $_;
    [
      join(";", reverse map {$_->{d}{name}}@{$lineage}),
      $lineage->[0]->{d}{name},
      $lineage->[0]->{d}{percent}
    ]
  } @lineagesAll;
  return @data;
}
sub estimateKbpInOnePercent {
  my @lineagesAll = @_;
  my @ratios = map {my $lineage = $_;
    $lineage->[0]->{d}{kbp} / $lineage->[0]->{d}{percent}
  } grep {my $lineage = $_;
   $lineage->[0]->{d}{kbp} && $lineage->[0]->{d}{percent} > 0 
  }@lineagesAll;
  return sum(@ratios) / scalar @ratios;

}

sub kbpFromLineages {
  my @lineagesAll = @_;
  my @data = map {my $lineage = $_;
    [
      join(";", reverse map {$_->{d}{name}}@{$lineage}),
      $lineage->[0]->{d}{name},
      $lineage->[0]->{d}{kbp}
    ]
  } grep {my $lineage = $_;
   $lineage->[0]->{d}{kbp} 
  }@lineagesAll;
  return @data;
}
sub dataToHash {
  my @data = @_;
  my %result;
  for my $t (@data){
    my ($string, $name, $abundance) = @$t;
    my @moreSpecificTaxa = grep { isSubTaxon($_->[0], $string) } @data;
    if (@moreSpecificTaxa){
      my @children = grep {
        my $string = $_->[0];
        not grep { isSubTaxon($string, $_->[0]) } @moreSpecificTaxa
      } @moreSpecificTaxa;
      $abundance = $abundance - sum (map {$_->[2]} @children);
    }
    next unless $abundance > 0;
    $result{$string} = $abundance;
  }
  return \%result;
}
