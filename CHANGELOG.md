## 1.0.2

* Fix wrong dial codes: Kazakhstan +7 (was +76), Vatican +39 (was +379), Bonaire, Sint Eustatius and Saba +599 (was +5997), Svalbard and Jan Mayen +47 (was +4779), and 23 countries and territories that share +1 (were +1 plus an area code, e.g. Jamaica +1876, US Virgin Islands "+1 340"). The area code is part of the national number.
* `getCountryByDialCode` now returns the main country when several countries share a dial code (e.g. US for +1, Russia for +7), accepts codes with or without `+`, and returns `null` instead of throwing when no country matches.
* Fix `filteredCountries`/`filterCountries`: `loadCountries(filterCountries: ...)` always threw `Bad state: No element`, and the picker widgets ignored the filter. Unknown entries are now skipped, and `CountryCodeWidget` and `AdvanceCountryCodeInputField` fall back to the first allowed country when Pakistan is filtered out.

## 1.0.1

* initial version
