## Considerations

* Can we assume that hyphens will always be present?
  * Probably not.
* Aren't Taxpayer Identification Numbers in the same format? Can we avoid including them?

## Regex rules

* 9 numbers
* hyphens may or may not be present
* all zeroes are not allowed in any field
* 666 and 990–999 are not allowed in the first field
* how do we avoid redacting Tax Identification Numbers?

## Regex

```
^(?!666|000|9\d{2})\d{3}(-?)(?!00)\d{2}(-?)(?!0{4})\d{4}$
````
