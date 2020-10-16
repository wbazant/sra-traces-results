# Get NCBI STAT metagenomics results

The data is displayed on the pages and on pretty Krona charts, but there seems to be no way to download them in a programmatic format.

This script downloads it from pages like `https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR8668755`.

## Install
Requires Perl (tested on version v5.26.1) and core modules. Should work for other perls too, but you might need to install something.

## Usage
There's a bit of an issue with the scraping, because the data is not given in one unit - below 0.01% are given as kbp, above (some) percent without kbp. 

To get the data for which percentage data is available:
```
 perl bin/getTaxaForStudy.pl PRJNA525604 0 

```

Get the data and attempt to convert it to kbp - approximates the ratio by taking an average ratio for where the values are available:
```
 perl bin/getTaxaForStudy.pl PRJNA525604 1 
```

## Result format
TSV. Values for taxa that also have children elsewhere represent "other", or summary values - for each run, the columns add up to the total value of mapped reads.

## License
This software is hereby released into the public domain.
