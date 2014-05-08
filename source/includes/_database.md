# Databases

Databases contain [documents](#documents), the JSON objects Cloudant revolves around. All documents need a database to contain them.

## Create

```shell
curl -X PUT https://$USERNAME.cloudant.com/$DATABASE
  -u $USERNAME
```

```python
import cloudant

account = cloudant.Account(USERNAME)
database = account.database(DATABASE)
response = database.put()
print response.status_code
# 201
```

> Example response:

```
{
  "ok": true
}
```

To create a database, make a PUT request to `https://$USERNAME.cloudant.com/$DATABASE`.

## Info

```shell
TODO
```

```python
TODO
```

> Example response:

```
{
  "update_seq": "0-g1AAAADneJzLYWBgYMlgTmFQSElKzi9KdUhJMtbLTS3KLElMT9VLzskvTUnMK9HLSy3JAapkSmRIsv___39WIgOqHkM8epIcgGRSPTZt-KzKYwGSDA1ACqhzP0k2QrQegGgF2ZoFAGdBTTo",
  "db_name": "db",
  "purge_seq": 0,
  "other": {
    "data_size": 0
  },
  "doc_del_count": 0,
  "doc_count": 0,
  "disk_size": 316,
  "disk_format_version": 5,
  "compact_running": false,
  "instance_start_time": "0"
}
```

Making a GET request against `https://$USERNAME.cloudant.com/$DATABASE` will return information about the database, such as how many documents it contains.

## List Databases

```shell
TODO
```

```python
TODO
```

> Example response:

```
[
   "_users",
   "contacts",
   "docs",
   "invoices",
   "locations"
]
```

To list all the databases in an account, make a GET request against `https://$USERNAME.cloudant.com/_all_dbs`.

## List Documents

```shell
TODO
```

```python
TODO
```

> Example response:

```
{
  "total_rows": 3,
  "offset": 0,
  "rows": [{
    "id": "5a049246-179f-42ad-87ac-8f080426c17c",
    "key": "5a049246-179f-42ad-87ac-8f080426c17c",
    "value": {
      "rev": "2-9d5401898196997853b5ac4163857a29"
    }
  }, {
    "id": "96f898f0-f6ff-4a9b-aac4-503992f31b01",
    "key": "96f898f0-f6ff-4a9b-aac4-503992f31b01",
    "value": {
      "rev": "2-ff7b85665c4c297838963c80ecf481a3"
    }
  }, {
    "id": "d1f61e66-7708-4da6-aa05-7cbc33b44b7e",
    "key": "d1f61e66-7708-4da6-aa05-7cbc33b44b7e",
    "value": {
      "rev": "2-cbdef49ef3ddc127eff86350844a6108"
    }
  }]
}
```

To list all the documents in a database, make a GET request against `https://$USERNAME.cloudant.com/$DATABASE/_all_docs`.

The method accepts these query arguments:

Argument | Description | Optional | Type | Default
---------|-------------|----------|------|--------
`descending` | Return the documents in descending by key order | yes | boolean | false
`endkey` | Stop returning records when the specified key is reached | yes | string |  
`include_docs` | Include the full content of the documents in the return | yes | boolean | false
`inclusive_end` | Include rows whose key equals the endkey | yes | boolean | true
`key` | Return only documents that match the specified key | yes | string |  
`limit` | Limit the number of the returned documents to the specified number | yes | numeric | 
`skip` | Skip this number of records before starting to return the results | yes | numeric | 0
`startkey` | Return records starting with the specified key | yes | string |

## List Changes

```shell
TODO
```

```python
TODO
```

> Example response:

```
{
  "results": [{
    "seq": "1-g1AAAAI9eJyV0EsKwjAUBdD4Ad2FdQMlMW3TjOxONF9KqS1oHDjSnehOdCe6k5oQsNZBqZP3HiEcLrcEAMzziQSB5KLeq0zyJDTqYE4QJqEo66NklQkrZUr7c8wAXzRNU-T22tmHGVMUapR2Bdwj8MBOvu4gscQyUtghyw-CYJ-SOWXTUSJMkKQ_UWgfsnXIuYOkhCCN6PBGqqmd4GKXda4OGvk0VCcCweHFeOjmoXubiEREIyb-KMdLDy89W4nTVGkqhhfkoZeHvkrimMJYrYo31bKsIg",
    "id": "foo",
    "changes": [{
      "rev": "1-967a00dff5e02add41819138abb3284d"
    }]
  }],
  "last_seq": "1-g1AAAAI9eJyV0EsKwjAUBdD4Ad2FdQMlMW3TjOxONF9KqS1oHDjSnehOdCe6k5oQsNZBqZP3HiEcLrcEAMzziQSB5KLeq0zyJDTqYE4QJqEo66NklQkrZUr7c8wAXzRNU-T22tmHGVMUapR2Bdwj8MBOvu4gscQyUtghyw-CYJ-SOWXTUSJMkKQ_UWgfsnXIuYOkhCCN6PBGqqmd4GKXda4OGvk0VCcCweHFeOjmoXubiEREIyb-KMdLDy89W4nTVGkqhhfkoZeHvkrimMJYrYo31bKsIg",
  "pending": 0
}
```

> Example response, continuous changes feed:

```
{
  "seq": "1-g1AAAAI7eJyN0EsOgjAQBuD6SPQWcgLSIm1xJTdRph1CCEKiuHClN9Gb6E30JlisCXaDbGYmk8mXyV8QQubZRBNPg6r2GGsI_BoP9YlS4auiOuqkrP0S68JcjhMCi6Zp8sxMO7OYISgUK3AF1iOAZyqsv8jog4Q6YIxyF4n6kLhFNs4nIQ-kUtJFwj5k2yJnB0lxSbkIhgdSTk0lF9OMc-0goCpikg7PxUI3C907KMKUM9AuJP9CDws9O0ghAtc4PB8LvSz0k5HgKTCU-RtU1qyw",
  "id": "2documentation22d01513-c30f-417b-8c27-56b3c0de12ac",
  "changes": [{
    "rev": "1-967a00dff5e02add41819138abb3284d"
  }]
}
{
  "seq": "2-g1AAAAI7eJyN0E0OgjAQBeD6k-gt5ASkRdriSm6iTDuEEIREceFKb6I30ZvoTbBYE-wG2cxMmubLyysIIfNsoomnQVV7jDUEfo2H-kSp8FVRHXVS1n6JdWF-jhMCi6Zp8sxcO_MwQ1AoVuAKrEcAz0xYf5HRBwl1wBjlLhL1IXGLbJwkIQ-kUtJFwj5k2yJnJ0mKS8pFMLyQcmomuZhlnGuXBqiKmKTDe7HQzUL3Doow5Qy0C8m_0MNCzw5SiMA1Du_HQi8L_RQteAoMZf4GVgissQ",
  "id": "1documentation22d01513-c30f-417b-8c27-56b3c0de12ac",
  "changes": [{
    "rev": "1-967a00dff5e02add41819138abb3284d"
  }]
}
{
  "seq": "3-g1AAAAI7eJyN0EsOgjAQBuD6SPQWcgLSIqW4kpso0w4hBCFRXLjSm-hN9CZ6EyyUBLtBNjOTyeTL5M8JIct0poijQJZHjBR4boWn6kJp4Mq8PKu4qNwCq1xfTmMCq7qus1RPB71YIEgMNmALbEAAR1fYdsikRXzlMUa5jYRDSNQgO-sTn3tCSmEj_hCyb5Brh0xbJME15YE3PpBiriu56aade_8NUBkyQcfnYqCHgZ49FGLCGSgbEn-hl4HePSQRgSscn4-BPgb6CTrgCTAU2RdXOqyy",
  "id": "1documentation22d01513-c30f-417b-8c27-56b3c0de12ac",
  "changes": [{
    "rev": "2-eec205a9d413992850a6e32678485900"
  }],
  "deleted": true
}
{
  "seq": "4-g1AAAAI7eJyN0EEOgjAQBdAGTfQWcgLSIm1xJTdRph1CCEKiuHClN9Gb6E30JlisCXaDbGYmTfPy80tCyDyfaOJrUPUeEw1h0OChOVEqAlXWR51WTVBhU5qfXkpg0bZtkZtrZx5mCArFClyBDQjgmwnrL-J9kEiHjFHuIvEQknTIxkkS8VAqJV0kGkK2HXJ2kmS4pFyE4wuppmaSi1nGufZpgKqYSTq-FwvdLHTvoRgzzkC7kPwLPSz07CGFCFzj-H4s9LLQT9GCZ8BQFm9Y9qyz",
  "id": "2documentation22d01513-c30f-417b-8c27-56b3c0de12ac",
  "changes": [{
    "rev": "2-eec205a9d413992850a6e32678485900"
  }],
  "deleted": true
}
```

Making a GET request against `https://$USERNAME.cloudant.com/$DATABASE/_changes` returns a list of changes made to documents in the database, including insertions, updates, and deletions. This log [may not be in chronological order](http://en.wikipedia.org/wiki/Clock_synchronization#Problems).

`_changes` accepts these query arguments:

Argument | Description | Optional | Type | Default | Supported Values
---------|-------------|----------|------|---------|-----------------
`doc_ids` | List of documents IDs to use to filter updates | yes | array of strings
`feed` | Type of feed | yes | string | normal | `continuous`, `longpoll`, `normal`
`filter` | Name of filter function from a design document to get updates | yes | string | |
`heartbeat` Time in milliseconds after which an empty line is sent during longpoll or continuous if there have been no changes | yes | numeric | 60000 | 
`include_docs` | Include the document with the result | yes | boolean | false |
`limit` Maximum number of rows to return | yes | numeric | none |  
`since` Start the results from changes after the specified sequence number. If since is 0 (the default), the request will return all changes. | yes | string | 0 | 
`descending` | Return the changes in sequential order | yes | boolean | false | 
`timeout` Number of milliseconds to wait for data before terminating the response. If heartbeat supersedes timeout if both are supplied. | yes | numeric | |

The `feed` argument changes how Cloudant sends the response. By default, changes feed in entirety and the connection closes.

If you set `feed=longpoll`, requests to the server remain open until changes are reported. This can help monitor changes specifically instead of continuously.

If you set `feed=continuous`, new changes send without closing the connection. In this mode the format of changes accomodates the continuous nature while ensuring validity of the JSON output.

The `filter` parameter designates a pre-defined [function to filter](#filter-functions) the changes feed.

## Delete

```shell
TODO
```

```python
TODO
```

> Example response:

```
{
  "ok": true
}
```

To delete a databases and its contents, make a DELETE request to `https://$USERNAME.cloudant.com/$DATABASE`.

## Reading Permissions

`GET /$DB/_security`

TODO

## Modifying Permissions

`PUT /$DB/_security`

TODO
