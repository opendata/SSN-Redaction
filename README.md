# SSN-Redaction

A redaction tool for Social Security Numbers in PDFs.

## Overview

Created in Ruby and Java, this tool accepts PDFs with embedded text and 1) detects the presence of Social Security Numbers, 2) removes the Social Security Numbers, and 3) draws a black box where the Social Security Number was, as a visual indicator of redaction.

## Options

* `--pages`: Comma separated list of ranges, or all.
* `--password`: Password to decrypt document.
* `--guess`: Guess the portion of each page to analyze.
* `--silent`: Suppress all stderr output.
* `--test`: Print detected SSN strings to stdout, do not write output PDF 

## License

Released under [the MIT License](https://github.com/USODI/SSN-Redaction/blob/master/LICENSE).
