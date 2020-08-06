# Hubspot input plugin for Embulk

## Overview

* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration

- **api_key**: hubspot api key (string, required)
- **object_type**: If you get all contacts data, set `"contact"`. (string, required)
- **columns**: Columns you want to get. If you don't set value, you can get all columns.(string)
  - **name**: the column name.
  - **type**: Column values are converted to this embulk type. (Available values options are: boolean, long, double, string, json, timestamp)

## Example

```yaml
in:
  type: hubspot
  api_key: example_api_key
  object_type: contact
  columns:
    - {name: createdAt, type: timestamp}
    - {name: id, type: long}
```


## Build

```
$ rake
```
