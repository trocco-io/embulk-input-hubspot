# Hubspot input plugin for Embulk

## Overview

* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration

- **api_key**: hubspot api key (string, required)
- **report_type**: If you get all contacts data, set `"get_all_contacts"`. (string, default: `"myvalue"`)
- **columns**: Columns you want to get. (string, required)
  - **name**: the column name.
  - **type**: Column values are converted to this embulk type. (Available values options are: boolean, long, double, string, json, timestamp)

## Example

```yaml
in:
  type: hubspot
  api_key: example_api_key
  report_type: get_all_contacts
  columns:
    - {name: addedAt, type: long}
    - {name: vid, type: long}
```


## Build

```
$ rake
```
