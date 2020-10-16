# Get NCBI STAT results

NCBI's SRA Taxonomy Analysis Tool (STAT) analyses metagenomic data available in SRA. The outputs are displayed on the pages as tables and as pretty Krona charts, but there seems to be no way to download them in a programmatic format.



## How it works
See the [STAT documentation page](https://www.ncbi.nlm.nih.gov/sra/docs/sra-taxonomy-analysis-tool/) for an overview of how the data is generated.

This program looks up a list of runs for a study, and then downloads the STAT results from pages like [this SRR8668755 results page](https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR8668755) by reading the HTML.

It recalculates the data from the aggregates at each taxonomic level, to partial sums, so that the values add up to the percentage of mapped reads.
Outputs are available as % - filtered at 0.01% and above - and as kbp, with all data.

It then formats it as a table in TSV format - rows labelled by taxa, columns are different samples.


## Install
Requires Perl (tested on version v5.26.1) and core modules. Should work for other perls too, but you might need to install something.

## Usage

To get the data for which percentage data is available:
```
 perl bin/getTaxaForStudy.pl PRJNA525604 0 

```

Get the data and attempt to convert it to kbp - approximates the ratio by taking an average ratio for where the values are available:
```
 perl bin/getTaxaForStudy.pl PRJNA525604 1 
```

### Caveats
The program could stop working if the format of the pages change.

There's a bit of an inaccuracy in the low abundance results. This is because the data is not given in one unit - below 0.01% the abundances are given only as kbp, and above (a few) percent, only as percent, without kbp.

## How to cite
Please cite STAT as source of the data, if you use it for something.

If you also want to reference this script, let me know, and I'll make a stable release of it through Zenodo or such.

## License
This software is hereby released into the public domain.
