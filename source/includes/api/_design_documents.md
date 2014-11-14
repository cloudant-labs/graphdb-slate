## Design Documents

Instead of storing data in a document,
you might also have special documents that store other content, such as functions.
The special documents are called "design documents".

Design documents are [documents](#documents) that have an `_id` beginning with `_design/`. They can thus be read and updated like any other document in the database.
Cloudant reads specific fields and values of design documents as functions.
Design documents are used to [build indexes](#indexes), [validate updates](#update-validators), and [format query results](#list-functions).

In these examples,
`$VARIABLES` might refer to standard and design documents.
To distinguish between them,
standard documents have an `_id` indicated by `$DOCUMENT_ID`,
while design documents have an `_id` indicated by `$DESIGN_ID`.

The structure of design document is as follows:

-   **\_id**: Design Document ID
-   **\_rev**: Design Document Revision
-   **views (optional)**: an object describing MapReduce views
    -   **viewname** (one for each view): View Definition
        -   **map**: Map Function for the view
        -   **reduce (optional)**: Reduce Function for the view
        -   **dbcopy (optional)**: Database name to store view results in
-   **indexes (optional)**: an object describing search indexes
    -   **index name** (one for each index): Index definition
        -   **analyzer**: Object describing the analyzer to be used or an object with the following fields:
            -   **name**: Name of the analyzer. Valid values are `standard`, `email`, `keyword`, `simple`, `whitespace`, `classic`, `perfield`.
            -   **stopwords (optional)**: An array of stop words. Stop words are words that should not be indexed. If this array is specified, it overrides the default list of stop words. The default list of stop words depends on the analyzer. The list of stop words for the standard analyzer is: "a", "an", "and", "are", "as", "at", "be", "but", "by", "for", "if", "in", "into", "is", "it", "no", "not", "of", "on", "or", "such", "that", "the", "their", "then", "there", "these", "they", "this", "to", "was", "will", "with".
            -   **default (for the per field analyzer)**: default language to use if there is no language specified for the field
            -   **fields (for the per field analyzer)**: An object specifying which language to use to analyze each field of the index. Field names in the object correspond to field names in the index (i.e. the first parameter of the index function). The values of the fields are the languages to be used, e.g. "english".
        -   **index**: Function that handles the indexing
-   **shows (optional)**: Show functions
    -   **function name** (one for each function): Function definition
-   **lists (optional)**: List functions
    -   **function name** (one for each function): Function definition

### Indexes

All queries operate on pre-defined indexes defined in design documents.
These indexes are:

* [Search](#search)
* [MapReduce](#mapreduce-views)
* [Geo](#geo)

For example,
to create a design document used for searching,
you must ensure that two conditions are true:

1. You have identified the document as a design document by having an `_id` starting with `_design/`.
2. A [search index](#search) has been created within the document by [updating](#update) the document with the appropriate field or by [creating](#create) a new document containing the search index.

As soon as the search index design document exists and the index has been built, you can make queries using it.

For more information about search indexing,
refer to the [search](#search) section of this documentation.

#### General notes on functions in design documents

Functions in design documents are run on multiple nodes for each document and might be run several times. To avoid inconsistencies, they need to be idempotent, meaning they need to behave identically when run multiple times and/or on different nodes. In particular, you should avoid using functions that generate random numbers or return the current time.


### List Functions

> Design doc with a list function:

```json
{
  "_id": "_design/list_example",
  "lists": {
    "FUNCTION_NAME": "function (head, req) { ... }"
  }
}
```

> Example list function:

```
function (head, req) {
  // specify our headers
  start({
    headers: {
      "Content-Type": 'text/html'
    }
  });
  // send the respond, line by line
  send('<html><body><table>');
  send('<tr><th>ID</th><th>Key</th><th>Value</th></tr>')
  while(row = getRow()){
    send(''.concat(
      '<tr>',
      '<td>' + toJSON(row.id) + '</td>',
      '<td>' + toJSON(row.key) + '</td>',
      '<td>' + toJSON(row.value) + '</td>',
      '</tr>'
    ));
  }
  send('</table></body></html>');
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_list/$LIST_FUNCTION/$MAPREDUCE_INDEX \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

db.view_with_list($DESIGN_ID, $MAPREDUCE_INDEX, $LIST_FUNCTION, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
```

Use list functions to customize the format of [MapReduce](#mapreduce) query results.

List functions require two arguments: `head` and `req`.

When you define a list function,
you use it by making a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_list/$LIST_FUNCTION/$MAPREDUCE_INDEX`.
In this request:

* `$LIST_FUNCTION` is the name of list function you defined.
* `$MAPREDUCE_INDEX` is the name of the index providing the query results you want to format.

The other parameters are the same query parameters used in a [MapReduce query](#queries).

#### head

Field | Description
------|-------------
total_rows | Number of documents in the view
offset | Offset where the document list started

#### req

Field | Description
------|-------------
body | Request body data as string. If the request method is GET this field contains the value "undefined". If the method is DELETE or HEAD the value is "" (empty string).
cookie | Cookies object.
form | Form data object. Contains the decoded body as key-value pairs if the Content-Type header was `application/x-www-form-urlencoded`.
headers | Request headers object.
id | Requested document id string if it was specified or null otherwise.
info | Database information
method | Request method as string or array. String value is a method as one of: HEAD, GET, POST, PUT, DELETE, OPTIONS, and TRACE. Otherwise it will be represented as an array of char codes.
path | List of requested path sections.
peer | Request source IP address.
query | URL query parameters object. Note that multiple keys are not supported and the last key value suppresses others.
requested_path | List of actual requested path section.
raw_path | Raw requested path string.
secObj | The database's [security object](#reading-permissions)
userCtx | Context about the currently authenticated user, specifically their `name` and `roles` within the current database.
uuid | A generated UUID

### Show Functions

> Design doc with a show function:

```json
{
  "_id": "_design/show_example",
  "shows": {
    "FUNCTION_NAME": "function (doc, req) { ... }"
  }
}
```

> Example show function:

```
function (doc, req) {
  if (doc) {
    return "Hello from " + doc._id + "!";
  } else {
    return "Hello, world!";
  }
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_show/$SHOW_FUNCTION/$DOCUMENT_ID \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

db.show($DESIGN_ID, $SHOW_FUNCTION, $DOCUMENT_ID, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

Show functions are like [list functions](#list-functions) but for formatting individual documents.

Show functions receive two arguments: `doc`, and [req](#req). `doc` is the document requested by the show function.

Once you've defined a show function, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/_show/$SHOW_FUNCTION/$DESIGN_ID`,
where `$SHOW_FUNCTION` is the function's name, and `$DESIGN_ID` is the `_id` of the document you want to run the show function on.

### Update Handlers

> Example design doc:

```json
{
  "_id": "_design/update_example",
  "updates": {
    "UPDATE_HANDLER_NAME": "function (doc, req) { ... }"
  }
}
```

> Example update handler:

```
function(doc, req){
  if (!doc){
    if ('id' in req && req.id){
      // create new document
      return [{_id: req.id}, 'New World']
    }
    // change nothing in database
    return [null, 'Empty World']
  }
  doc.world = 'hello';
  doc.edited_by = req.userCtx.name
  return [doc, 'Edited World!']
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_update/$UPDATE_HANDLER \
     -X POST \
     -H "Content-Type: application/json" \
     -u $USERNAME
     -d "$JSON"
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

db.atomic($DESIGN_ID, $UPDATE_HANDLER, $DOCUMENT_ID, $JSON, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

Update handlers are custom functions that live on Cloudant's server that will create or update a document.
This can, for example, provide server-side modification timestamps, and document updates to individual fields without the latest revision. 

Update handlers receive two arguments: `doc` and [req](#req).
If a document ID is provided in the request to the update handler, then `doc` will be the document corresponding with that ID. If no ID was provided, `doc` will be `null`.

Update handler functions must return an array of two elements, the first being the document to save (or null, if you don't want to save anything), and the second being the response body.

Here's how to query update handlers:

Method | URL
-------|------
POST | `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_update/$UPDATE_HANDLER`
PUT | `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_update/$UPDATE_HANDLER/$DOCUMENT_ID`

Where `$DESIGN_ID` is the `_id` of the document defining the update handler, `$UPDATE_HANDLER` is the name of the update handler, and `$DOCUMENT_ID` is the `_id` of the document you want the handler to, well, handle.

### Filter Functions

> Example design document:

```json
{
  "_id":"_design/FILTER_EXAMPLE",
  "filters": {
    "FILTER_EXAMPLE": "function (doc, req) { ... }"
  }
}
```

> Example filter function:

```
function(doc, req){
  // we need only `mail` documents
  if (doc.type !== 'mail'){
    return false;
  }
  // we're interested only in `new` ones
  if (doc.status !== 'new'){
    return false;
  }
  return true; // passed!
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_changes?filter=$DESIGN_ID%2F$FILTER \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");

account.db.changes($DATABASE, {
  // ex: example/filter
  filter: [$DESIGN_ID, $FILTER_FUNCTION].join('/')
}, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
```

Filter functions format the [changes feed](#list-changes), removing changes you don't want to monitor.
The filter function is run over every change in the changes feed, and only those for which the function returns `true` are returned to the client in the response.

Filter functions receive two arguments: `doc` and [req](#req). `doc` represents the document currently being filtered.

To use a filter function on the changes feed, specify the function in the `_changes` query. See the examples for more details.

### Update Validators

> Example design document:

```json
{
  "_id": "_design/validator_example",
  "validate_doc_update": "function(newDoc, oldDoc, userCtx, secObj) { ... }"
}
```

> Example update validator:

```
function(newDoc, oldDoc, userCtx, secObj) {
  if (newDoc.address === undefined) {
     throw({forbidden: 'Document must have an address.'});
  }
}
```

> Example response:

```json
{
  "error": "forbidden",
  "reason": "Document must have an address."
}
```

Update validators evaluate whether a document should be written to disk when insertions and updates are attempted.
They do not require a query because they implicitly run during this process. If a change is rejected, the update validator responds with a custom error. 

Update validators get four arguments:

* `newDoc`: the version of the document passed in the request.
* `oldDoc`: the version of the document currently in the database, or `null` if there is none.
* `userCtx`: context about the currently authenticated user, such as `name` and `roles`..
* `secObj`: the database's [security object](#reading-permissions)

### Retrieving information about a design document

> Example to get the information for the `recipes` design document:

```
GET /recipes/_design/recipes/_info
Content-Type: application/json
```

> Example JSON structure response:

```json
{
   "name" : "recipes"
   "view_index" : {
      "compact_running" : false,
      "updater_running" : false,
      "language" : "javascript",
      "purge_seq" : 10,
      "waiting_commit" : false,
      "waiting_clients" : 0,
      "signature" : "fc65594ee76087a3b8c726caf5b40687",
      "update_seq" : 375031,
      "disk_size" : 16491
   },
}
```

-   **Method**: `GET /db/_design/design-doc/_info`
-   **Request**: None
-   **Response**: JSON of the design document information
-   **Roles permitted**: \_reader

Obtains information about a given design document, including the index, index size and current status of the design document and associated index information.

The individual fields in the returned JSON structure are detailed below:

-   **name**: Name/ID of Design Document
-   **view\_index**: View Index
    -   **compact\_running**: Indicates whether a compaction routine is currently running on the view
    -   **disk\_size**: Size in bytes of the view as stored on disk
    -   **language**: Language for the defined views
    -   **purge\_seq**: The purge sequence that has been processed
    -   **signature**: MD5 signature of the views for the design document
    -   **update\_seq**: The update sequence of the corresponding database that has been indexed
    -   **updater\_running**: Indicates if the view is currently being updated
    -   **waiting\_clients**: Number of clients waiting on views from this design document
    -   **waiting\_commit**: Indicates if there are outstanding commits to the underlying database that need to processed
