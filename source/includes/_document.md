# Documents

Documents are [JSON objects](http://en.wikipedia.org/wiki/JSON#Data_types.2C_syntax_and_example), containers for your data and the vital organs of the Cloudant database.

All documents have a unique `_id` field, either assigned by you or generated as a UUID by Cloudant, and a `_rev` field, which is essential to Cloudant's replication protocol. Beyond those, documents can contain anything a JSON might.

## Create

```shell
TODO
```

```python
TODO
```

> Example document:

```json
{
  "_id": "apple",
  "item": "Malus domestica",
  "prices": {
    "Fresh Mart": 1.59,
    "Price Max": 5.99,
    "Apples Express": 0.79
  }
}
```

> Example response:

```json
{
  "ok":true,
  "id":"apple",
  "rev":"1-2902191555"
}
```

To create a document, make a POST request with the document's JSON content to `https://$USERNAME.cloudant.com/$DATABASE`. If you don't provide an `_id` field, Cloudant will generate one as a [UUID](http://en.wikipedia.org/wiki/Universally_unique_identifier) for the document. 

## Read

```shell
TODO
```

```python
TODO
```

> Example response:

```json
{
  "_id": "apple",
  "_rev": "1-2902191555",
  "item": "Malus domestica",
  "prices": {
    "Fresh Mart": 1.59,
    "Price Max": 5.99,
    "Apples Express": 0.79
  }
}
```

To retrieve a document, make a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC` where `$DOC` is the document's `_id`.

## List

To fetch many documents at once, see [Database: List Documents](#list-documents).

## Update

```shell
TODO
```

```python
TODO
```

> Example request body:

```json
{
  "_id": "apple",
  "_rev": "1-2902191555",
  "item": "Malus domestica",
  "prices": {
    "Fresh Mart": 1.59,
    "Price Max": 5.99,
    "Apples Express": 0.79,
    "Gentlefop's Shackmart": 0.49
  }
}
```

> Example response:

```json
{
  "ok":true,
  "id":"apple",
  "rev":"2-9176459034"
}
```

To update a document, make a PUT request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC` where `$DOC` is the document's `_id`, and the updated document JSON is the request body, including the document's latest `_rev` value.

<aside>If you don't provide the latest `_rev`, or provide an outdated `_rev`, Cloudant will respond with a 409 error, to prevent overwriting data changed by other clients.</aside>

## Delete

```shell
TODO
```

```python
TODO
```

> Example response:

```json
{
   "id" : "apple",
   "ok" : true,
   "rev" : "3-2719fd4118"
}
```

To delete a document, make a DELETE request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC` with the document's latest `_rev` in the querystring.

<aside>If you don't provide the latest `_rev`, or provide an outdated `_rev`, Cloudant will respond with a 409 error, to prevent overwriting data changed by other clients.</aside>

## Bulk Operations

```shell
TODO
```

```python
TODO
```

> Example request body:

```json
{
  "docs": [
    {
      "name": "Nicholas",
      "age": 45,
      "gender": "female",
      "_id": "96f898f0-f6ff-4a9b-aac4-503992f31b01",
      "_rev": "1-54dd23d6a630d0d75c2c5d4ef894454e"
    },
    {
      "name": "Taylor",
      "age": 50,
      "gender": "female"
    },
    {
      "name": "Owen",
      "age": 51,
      "gender": "female",
      "_id": "d1f61e66-7708-4da6-aa05-7cbc33b44b7e",
      "_rev": "1-a2b6e5dac4e0447e7049c8c540b309d6",
      "_deleted": true
    }
  ]
}
```

> Example response:

```json
[{
  "id": "96f898f0-f6ff-4a9b-aac4-503992f31b01",
  "rev": "2-ff7b85665c4c297838963c80ecf481a3"
}, {
  "id": "5a049246-179f-42ad-87ac-8f080426c17c",
  "rev": "2-9d5401898196997853b5ac4163857a29"
}, {
  "id": "d1f61e66-7708-4da6-aa05-7cbc33b44b7e",
  "rev": "2-cbdef49ef3ddc127eff86350844a6108"
}]
```

To make many insertions, updates, and/or deletes simultaneously, make a POST request to `https://$USERNAME.cloudant.com/$DATABASE/_bulk_docs`. Cloudant will process each contained action, and return a list of results for each.
