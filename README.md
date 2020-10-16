# Get NCBI STAT metagenomics results

The data is displayed on the pages and on pretty Krona charts, but there seems to be no way to download them in a programmatic format.

This script downloads it from pages like `https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR8668755`.

## Install
Requires Perl (tested on version v5.26.1) and core modules. Should work for other perls too, but you might need to install something.

## Usage
To get the most abundant data for which percentage data is available:
```
 perl bin/getTaxaForStudy.pl PRJNA525604 0 

```

Get the data given in kilobases - approximates % to kbp for the larger values, where only % is given:

```
 perl bin/getTaxaForStudy.pl PRJNA525604 1 
```

## Result format
TSV. Values for taxa that also have children elsewhere represent "other", or summary values - for each run, the columns add up to the total value of mapped reads.

## License
This software is hereby released into the public domain.
