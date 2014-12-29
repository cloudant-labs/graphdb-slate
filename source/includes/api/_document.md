## Documents

Documents are [JSON objects](http://en.wikipedia.org/wiki/JSON#Data_types.2C_syntax_and_example).
Documents are containers for your data, and are the basis of the Cloudant database.

All documents must have two fields:
a unique `_id` field, and a `_rev` field.
The `_id` field is either created by you,
or generated automatically as a [UUID](http://en.wikipedia.org/wiki/Universally_unique_identifier) by Cloudant.
The `_rev` field is a revision number, and is [essential to Cloudant's replication protocol](guides.html#document-versioning-and-mvcc).
In addition to these two mandatory fields, documents can contain any other content expressed using JSON.

<h3 id="documentCreate">Create</h3>

> Example instruction for creating a document:

```http
POST /$DATABASE HTTP/1.1
Content-Type: application/json
```

```shell
curl https://$USERNAME.cloudant.com/$DATABASE \
     -X POST \
     -u $USERNAME \
     -H "Content-Type: application/json" \
     -d "$JSON"
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

db.insert($JSON, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
```

> Example document to be created:

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

To create a document, make a POST request with the document's JSON content to `https://$USERNAME.cloudant.com/$DATABASE`.
If you do not provide an `_id` field, Cloudant generates one automatically as a [UUID](http://en.wikipedia.org/wiki/Universally_unique_identifier). 

### Read

> Example instruction for reading a document:

```http
GET /$DATABASE/$DOCUMENT_ID HTTP/1.1
```

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

db.get($JSON._id, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
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

To retrieve a document, make a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID`.
If you do not know the `_id` for a particular document,
you can [query the database](#get-documents) for all documents.

### Read Many

To fetch many documents at once, [query the database](#get-documents).

### Update

> Example instruction for updating a document:

```http
PUT /$DATABASE/$DOCUMENT_ID HTTP/1.1
```

```shell
// make sure $JSON contains the correct `_rev` value!
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID \
     -X PUT \
     -u $USERNAME \
     -H "Content-Type: application/json" \
     -d "$JSON"
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

// make sure $JSON contains the correct `_rev` value!
$JSON._rev = $REV;

db.insert($JSON, $JSON._id, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
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

To update (or create) a document, make a PUT request with the updated JSON content *and* the latest `_rev` value (not needed for creating new documents) to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID`.

<aside>If you fail to provide the latest `_rev`, Cloudant responds with a [409 error](basics.html#http-status-codes).
This error prevents you overwriting data changed by other clients.</aside>

<div id="document-delete"></div>

### Delete

> Example instruction for deleting a document:

```http
DELETE /$DATABASE/$DOCUMENT_ID?rev=$REV HTTP/1.1
```

```shell
// make sure $JSON contains the correct `_rev` value!
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID?rev=$REV \
     -X DELETE \
     -u $USERNAME \
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

// make sure $JSON contains the correct `_rev` value!
db.destroy($JSON._id, $REV, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
```

> Example response:

```json
{
   "id" : "apple",
   "ok" : true,
   "rev" : "3-2719fd4118"
}
```

To delete a document, make a DELETE request with the document's latest `_rev` in the querystring, to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID`.

<aside>If you fail to provide the latest `_rev`, Cloudant responds with a [409 error](basics.html#http-status-codes).
This error prevents you overwriting data changed by other clients.</aside>

<aside class="warning">
CouchDB doesn’t completely delete the specified document. Instead, it leaves a tombstone with very basic information about the document. The tombstone is required so that the delete action can be replicated. Since the tombstones stay in the database indefinitely, creating new documents and deleting them increases the disk space usage of a database and the query time for the primary index, which is used to look up documents by their ID.
</aside>

### Bulk Operations

> Example instruction for performing bulk operations:

```http
POST /$DATABASE/_bulk_docs HTTP/1.1
Content-Type: application/json
```

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_bulk_docs \
     -X POST \
     -u $USERNAME \
     -H "Content-Type: application/json" \
     -d "$JSON"
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.bulk($JSON, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
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

To make multiple, simultaneous requests such as insertions, updates, or deletes, make a POST request to `https://$USERNAME.cloudant.com/$DATABASE/_bulk_docs`.
Cloudant processes and returns the results for each of the requested actions.
