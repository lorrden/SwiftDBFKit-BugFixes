# SwiftDBFKit Change Log

## 1.3

### Added Features

Support for reading/writing timestamp fields. This now means that DBFKit officially supports reading/writing all field types!

Also a few more functions were added to help retrieve blocks in the DBT file more easily. Specifically, one can now extract all the DBT blocks (unmerged when one block stretches over another) and get an array holding all those blocks, or extract the DBT blocks merged (when one block stretches over another) and get a dictionary representation of it all.

### Bug Fixes

A minor bug in the canAddColumns() (part of DBFTable class) function which returned the wrong value.

## 1.2

### Added Features

Support for reading/writing field types:

- Memo/OLE/Binary
- Long/Autoincrement
- Double
                
Support for detecting the encryption flag and incomplete transaction flag has also been added
                
### Other Changes

Improved time complexity and documentation in a few areas.

## 1.1

Minor bug fixes. Also added support for reading/writing deleted records.

## 1.0

Initial release
